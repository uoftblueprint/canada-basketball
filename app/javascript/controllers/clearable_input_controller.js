import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["field", "clear"];

  connect() {
    this.toggle();
  }

  toggle() {
    this.clearTarget.hidden = this.fieldTarget.value.trim() === "";
  }

  clear() {
    this.fieldTarget.value = "";
    this.toggle();
    this.fieldTarget.focus();
    this.element.requestSubmit();
  }
}
