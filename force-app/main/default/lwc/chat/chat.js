import getAvailableChannels from "@salesforce/apex/Chat.getAvailableChannels";
import getConversations from "@salesforce/apex/Chat.getConversations";
import { api, LightningElement, wire } from "lwc";

export default class Chat extends LightningElement {
  @api recordId;
  messages;
  conversations;
  channels;

  @wire(getAvailableChannels, { recordId: "$recordId" })
  wiredChannels(result) {
    if (result.data) {
      this.channels = result.data;
    }
  }

  @wire(getConversations, { recordId: "$recordId" })
  wiredConversations(result) {
    if (result.data) {
      this.conversations = result.data;
    }
  }
}
