import { Controller } from "@hotwired/stimulus";
import _ from "lodash";

export default class extends Controller {
  static values = {
    debounceLeading: { default: true, type: Boolean },
    debounceMaxWait: { default: 0, type: Number }, // Set to -1 for no max wait
    debounceTrailing: { default: true, type: Boolean },
    debounceWaitTimeout: { default: 400, type: Number },
  };

  get debounceOptions() {
    const options = {
      leading: this.debounceLeadingValue,
      trailing: this.debounceTrailingValue,
    };

    if (this.debounceMaxWaitValue > -1) {
      options.maxWait = this.debounceMaxWaitValue;
    }

    return options;
  }

  initialize() {
    this.trigger = _.debounce(
      this.trigger,
      this.debounceWaitTimeoutValue,
      this.debounceOptions,
    );
  }

  trigger() {
    let form;

    if (this.element.tagName == "FORM") {
      form = this.element;
    } else {
      form = this.element.form;
    }

    if (!form) return;

    const submitButton = form.querySelector("[type=submit]");
    if (submitButton) submitButton.disabled = true;

    const reload = document.createElement("input");
    reload.name = "reload";
    reload.type = "hidden";
    reload.value = "true";

    // Change form attributes
    form.setAttribute("novalidate", true); // without this any invalid fields will prevent the form reloading
    form.appendChild(reload);

    // Trigger a custom event
    const event = new Event("js:form-reload");
    document.documentElement.dispatchEvent(event);

    // Submit the form
    form.requestSubmit();

    // Reset form attributes
    form.removeAttribute("novalidate");
    form.removeChild(reload);
  }
}
