import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["price"];

  checkRoomPrice(event) {
    const checkbox = event.currentTarget;
    if (checkbox.checked) {
      this.priceTarget.disabled = true;
    } else {
      this.priceTarget.disabled = false;
    }
  }
}
