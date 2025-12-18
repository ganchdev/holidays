import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["monthHeader", "scrollContainer", "daysList", "day"];

  connect() {
    this.setRoomIndices();
    this.observeDays();
    this.scrollToCurrentDay();
    this.scrollToSaved();

    document.addEventListener("turbo:before-visit", this.saveScroll);
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect();
    }

    document.removeEventListener("turbo:before-visit", this.saveScroll);
  }

  setRoomIndices() {
    const roomRows = this.element.querySelectorAll(".room-row");
    roomRows.forEach((row, index) => {
      const roomId = row.dataset.roomId;
      const bookingSpans = this.element.querySelectorAll(
        `.booking-span[data-room-id="${roomId}"]`,
      );
      bookingSpans.forEach((span) => {
        span.style.setProperty("--room-index", index);
      });
    });
  }

  saveScroll = () => {
    if (this.hasScrollContainerTarget) {
      sessionStorage.setItem(
        "horizontal-calendar-scroll",
        this.scrollContainerTarget.scrollLeft,
      );
    }
  };

  scrollToSaved() {
    const scrollX = sessionStorage.getItem("horizontal-calendar-scroll");
    if (scrollX && this.hasScrollContainerTarget) {
      this.scrollContainerTarget.scrollLeft = parseInt(scrollX, 10);
      sessionStorage.removeItem("horizontal-calendar-scroll");
    }
  }

  observeDays() {
    const dayHeaders = this.element.querySelectorAll(".day-header");
    if (!dayHeaders.length) return;

    this.observer = new IntersectionObserver(this.onDayIntersect.bind(this), {
      root: this.scrollContainerTarget,
      rootMargin: "0px -50% 0px -50%",
      threshold: 0,
    });

    dayHeaders.forEach((day) => this.observer.observe(day));
  }

  onDayIntersect(entries) {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        this.updateMonthHeader(entry.target);
      }
    });
  }

  scrollToCurrentDay() {
    const today = new Date();
    const todayString = this.formatDateString(today);

    const currentDay = this.element.querySelector(
      `.day-header[data-date="${todayString}"]`,
    );
    const scrollableContainer = this.element.querySelector(
      ".scrollable-calendar",
    );

    if (currentDay && scrollableContainer) {
      // Scroll to center the current day
      const containerWidth = scrollableContainer.clientWidth;
      const dayWidth = currentDay.clientWidth;
      const dayOffset = currentDay.offsetLeft;

      const scrollLeft = dayOffset - containerWidth / 2 + dayWidth / 2;

      scrollableContainer.scrollLeft = Math.max(0, scrollLeft);
      this.updateMonthHeader(currentDay);
    }
  }

  updateMonthHeader(dayElement) {
    if (!dayElement || !this.hasMonthHeaderTarget) return;

    const date = new Date(dayElement.dataset.date);
    const monthName = this.getMonthName(date);
    const year = date.getFullYear();

    this.monthHeaderTarget.textContent = `${monthName} ${year}`;
  }

  formatDateString(date) {
    return date.toISOString().split("T")[0];
  }

  getMonthName(date) {
    // Use custom i18n month names if available
    if (window.i18n && window.i18n.months) {
      return window.i18n.months[date.getMonth()];
    }

    // Fallback to browser's locale
    const currentLocale = window.appLocale || "bg";
    return date.toLocaleDateString(currentLocale, { month: "long" });
  }
}
