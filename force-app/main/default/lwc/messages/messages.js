import { api, LightningElement } from "lwc";

export default class Messages extends LightningElement {
  _messages;

  @api
  get messages() {
    return this._messages;
  }
  set messages(v) {
    let items;
    if (v !== undefined) {
      items = [...v].reverse();
    }
    this._messages = items;
  }
}
