import { api, LightningElement } from "lwc";

export default class ChatInput extends LightningElement {
  message = "";
  loading = false;

  get isButtonDisabled() {
    return !this.validMessage || this.loading;
  }

  get validMessage() {
    return this.message !== undefined && this.message !== "";
  }

  @api
  notifyMessagePublished() {
    this.loading = false;
    this.message = "";
  }

  handleInputChange(e) {
    const message = e.detail.value;
    this.message = message;
  }

  handleClick() {
    if (!this.validMessage) {
      return;
    }
    this.loading = true;
    this.dispatchEvent(
      new CustomEvent("sendmessage", { detail: { message: this.message } })
    );
  }
}
