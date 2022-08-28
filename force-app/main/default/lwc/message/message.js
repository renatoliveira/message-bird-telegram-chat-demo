import { api, LightningElement } from "lwc";
import inbound from "./inbound.html";
import outbound from "./outbound.html";
import base from "./message.html";

export default class Message extends LightningElement {
  @api message;

  render() {
    if (this.message === undefined) {
      return base;
    }

    if (this.message.direction === "sent") {
      return outbound;
    }

    return inbound;
  }

  get timestamp() {
    return this.message?.updatedDatetime;
  }

  get textContent() {
    return this.message?.content?.text;
  }
}
