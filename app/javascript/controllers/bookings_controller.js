import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["backLink"];

  connect() {
    if (this.hasBackLinkTarget) {
      const path = sessionStorage.getItem("backPath");
      this.backLinkTarget.href = path;
    }
  }

  setPath(e) {
    const path = e.currentTarget.dataset.path;
    sessionStorage.removeItem("backPath");
    sessionStorage.setItem("backPath", path);
  }
}
