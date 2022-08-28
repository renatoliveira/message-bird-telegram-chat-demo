import { api, LightningElement, wire } from "lwc";
import getConversations from "@salesforce/apex/Chat.getConversations";

export default class ChatChannel extends LightningElement {
  @api channelId;
  @api recordId;
  conversations;

  get conversationCount() {
    return this.conversations !== undefined ? this.conversations.length : 0;
  }

  @wire(getConversations, { recordId: "$recordId", channelId: "$channelId" })
  wiredConversations(result) {
    if (result.data) {
      this.conversations = result.data;
    }
  }
}
