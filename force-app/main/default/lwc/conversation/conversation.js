import getMessages from "@salesforce/apex/Chat.getMessages";
import { api, LightningElement, wire } from "lwc";
import { refreshApex } from "@salesforce/apex";
import replyConversation from "@salesforce/apex/Chat.replyConversation";
import { parseError } from "c/errorHandler";

const REFRESH_TIMER_MILLIS = 3000;
const MAX_REFRESH_TIMER_MILLIS = REFRESH_TIMER_MILLIS * 5;

export default class Conversation extends LightningElement {
  @api conversationId;
  messages;
  _lastReceivedMessage;
  _lastMessage;
  _wiredResult;
  _refreshTimerInMillis = REFRESH_TIMER_MILLIS;

  get messageCount() {
    return this.messages !== undefined ? this.messages.length : 0;
  }

  @wire(getMessages, { conversationId: "$conversationId" })
  wiredMessages(result) {
    this._wiredResult = result;

    if (!this._wiredResult.data) {
      return;
    }

    if (this._wiredResult.data.hasError) {
      console.error(`Errors`);
      console.error(JSON.parse(JSON.stringify(this._wiredResult.data)));
      return;
    }

    this.messages = this._wiredResult.data.data.items;

    if (this.messages.length !== 0) {
      this._lastMessage = this.messages[0];
      this._lastReceivedMessage = this.messages.find(
        (el) => el.direction === "received"
      );
    }

    this.scheduleRefresh();
  }

  scheduleRefresh() {
    if (window.location.href.includes("flexipageEditor/surface.app")) {
      // Within visual editor (App Builder), so avoid querying any more.
      return;
    }

    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      if (this.refresh !== undefined) {
        this.refresh().bind(this);
      }
    }, this._refreshTimerInMillis);
  }

  refresh() {
    refreshApex(this._wiredResult).then(() => {
      if (this.messages.length === 0) {
        return;
      }

      if (
        this._lastMessage.id === this.messages[0].id &&
        this._refreshTimerInMillis < MAX_REFRESH_TIMER_MILLIS
      ) {
        this._refreshTimerInMillis += 1000;
      } else if (this._lastMessage.id !== this.messages[0].id) {
        this._refreshTimerInMillis = REFRESH_TIMER_MILLIS;
        this._lastMessage = this.messages[0];
        this._lastReceivedMessage = this.messages.find(
          (el) => el.direction === "received"
        );
      }

      this.scheduleRefresh();
    });
  }

  handleSendMessage(e) {
    const text = e.detail.message;

    if (!this._lastReceivedMessage) {
      return;
    }

    const msg = {
      content: text,
      type: "text",
      conversationId: this._lastReceivedMessage.conversationId
    };

    replyConversation({ params: msg })
      .then(() => {
        const chatInput = this.template.querySelector("c-chat-input");

        refreshApex(this._wiredResult);
        this._refreshTimerInMillis = REFRESH_TIMER_MILLIS;

        if (chatInput) {
          chatInput.notifyMessagePublished();
        }
      })
      .catch((err) => {
        console.error(`Something went wrong: ${parseError(err)}`);
      });
  }
}
