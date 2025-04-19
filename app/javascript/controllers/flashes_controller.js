import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  handleTurboVisit = () => {
    this.element.remove();
  };

  connect() {
    document.addEventListener("turbo:visit", this.handleTurboVisit);
  }

  disconnect() {
    document.removeEventListener("turbo:visit", this.handleTurboVisit);
  }
}
