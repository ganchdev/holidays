import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["weekHeader", "list", "week"];

  connect() {
    this.observeWeeks();
    this.scrollToCurrentWeek();
    this.scrollToSaved();

    document.addEventListener("turbo:before-visit", this.saveScroll);
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect();
    }

    document.removeEventListener("turbo:before-visit", this.saveScroll);
  }

  saveScroll = () => {
    if (this.hasListTarget) {
      sessionStorage.setItem("calendar-scroll", this.listTarget.scrollTop);
    }
  };

  scrollToSaved() {
    const scrollY = sessionStorage.getItem("calendar-scroll");
    if (scrollY && this.hasListTarget) {
      this.listTarget.scrollTop = parseInt(scrollY, 10);
      sessionStorage.removeItem("calendar-scroll");
    }
  }

  observeWeeks() {
    if (!this.hasWeekTarget) return;

    this.observer = new IntersectionObserver(this.onWeekIntersect.bind(this), {
      root: null,
      threshold: 0.5,
    });

    this.weekTargets.forEach((week) => this.observer.observe(week));
  }

  onWeekIntersect(entries) {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        this.updateWeekHeader(entry.target);
      }
    });
  }

  scrollToCurrentWeek() {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const currentWeek = this.weekTargets.find((week) => {
      const weekStart = new Date(week.dataset.week);
      weekStart.setHours(0, 0, 0, 0);

      const weekEnd = new Date(weekStart);
      weekEnd.setDate(weekStart.getDate() + 6);
      weekEnd.setHours(0, 0, 0, 0);

      return today >= weekStart && today <= weekEnd;
    });

    if (currentWeek) {
      currentWeek.scrollIntoView({ behavior: "instant", block: "start" });
      this.updateWeekHeader(currentWeek);
    }
  }

  updateWeekHeader(weekElement) {
    if (!weekElement) return;

    const weekStartDate = new Date(weekElement.dataset.week);
    const weekEndDate = new Date(weekStartDate);
    weekEndDate.setDate(weekStartDate.getDate() + 6);

    // Format date with capitalized month names from our i18n data
    const formatDate = (date) => {
      const day = date.getDate();
      const monthIndex = date.getMonth();
      
      // Use our custom month names if available
      let monthName;
      if (window.i18n && window.i18n.months) {
        monthName = window.i18n.months[monthIndex];
      } else {
        // Fallback to browser's locale
        const currentLocale = window.appLocale || "bg";
        monthName = date.toLocaleDateString(currentLocale, { month: 'long' });
      }
      
      return `${day} ${monthName}`;
    };

    const firstDay = formatDate(weekStartDate);
    const lastDay = formatDate(weekEndDate);
    const year = weekStartDate.getFullYear();

    this.weekHeaderTarget.textContent = `${firstDay} - ${lastDay}, ${year}`;
  }
}
