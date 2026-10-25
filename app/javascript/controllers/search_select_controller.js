import { Controller } from "@hotwired/stimulus";

const DEBOUNCE_MS = 300;

export default class extends Controller {
  static targets = [
    "input",
    "results",
    "selected",
    "value",
    "badgeTemplate",
    "option",
    "clear",
  ];
  static values = {
    multiple: Boolean,
    url: String,
    paramScope: String,
    minChars: { type: Number, default: 0 },
  };

  connect() {
    this.activeIndex = -1;
    this.debounceTimer = null;
    this.selectedIds = new Set(this.initialSelectedIds());
    this.toggleClear();
  }

  initialSelectedIds() {
    // Multiple select initial selections
    if (this.hasSelectedTarget) {
      return Array.from(this.selectedTarget.querySelectorAll("[data-id]")).map(
        (element) => element.dataset.id,
      );
    }

    // Single select initial selections
    if (this.hasValueTarget && this.valueTarget.value) {
      return [this.valueTarget.value];
    }

    return [];
  }

  disconnect() {
    clearTimeout(this.debounceTimer);
  }

  search() {
    this.toggleClear();
    clearTimeout(this.debounceTimer);

    // Clear the value for single-select once the input changes
    if (!this.multipleValue && this.hasValueTarget) {
      this.valueTarget.value = "";
      this.selectedIds.clear();
    }

    const query = this.inputTarget.value.trim();
    if (query.length < this.minCharsValue) {
      this.close();
      return;
    }

    this.debounceTimer = setTimeout(() => this.reload(query), DEBOUNCE_MS);
  }

  open() {
    const query = this.inputTarget.value.trim();

    if (this.minCharsValue > 0 && query.length < this.minCharsValue) {
      return;
    }

    this.reload(query);
  }

  reload(query) {
    const url = new URL(this.urlValue, window.location.origin);
    const scope = this.paramScopeValue;
    const keyedQueryParam = scope ? `${scope}[q]` : "q";
    const keyedSelectedIdParam = scope ? `${scope}[selected][]` : "selected[]";

    url.searchParams.set(keyedQueryParam, query);
    this.selectedIds.forEach((id) =>
      url.searchParams.append(keyedSelectedIdParam, id),
    );

    // Triggers a Turbo fetches & swaps the frame
    this.resultsTarget.src = url.toString();
    this.showResults();
  }

  showResults() {
    this.resultsTarget.classList.remove("hidden");
    this.inputTarget.setAttribute("aria-expanded", "true");
    this.activeIndex = -1;
  }

  close() {
    this.resultsTarget.classList.add("hidden");
    this.inputTarget.setAttribute("aria-expanded", "false");
    this.inputTarget.removeAttribute("aria-activedescendant");
    this.activeIndex = -1;
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close();
    }
  }

  navigate(event) {
    const options = this.selectableOptions();

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault();
        // Open results list if hidden on arrow down
        if (this.resultsTarget.classList.contains("hidden")) {
          this.open();
          return;
        }
        this.setActive(Math.min(this.activeIndex + 1, options.length - 1));
        break;
      case "ArrowUp":
        event.preventDefault();
        this.setActive(Math.max(this.activeIndex - 1, 0));
        break;
      case "Enter":
        if (this.activeIndex >= 0 && options[this.activeIndex]) {
          event.preventDefault();
          this.choose(options[this.activeIndex]);
        }
        break;
      case "Escape":
        this.close();
        break;
    }
  }

  selectableOptions() {
    return this.optionTargets.filter((o) => !o.disabled);
  }

  setActive(index) {
    this.activeIndex = index;

    const options = this.selectableOptions();
    options.forEach((o, i) => o.setAttribute("aria-selected", i === index));

    const active = options[index];
    if (active) {
      this.inputTarget.setAttribute("aria-activedescendant", active.id);
      active.scrollIntoView({ block: "nearest" });
    }
  }

  highlight(event) {
    const idx = this.selectableOptions().indexOf(event.currentTarget);

    if (idx >= 0) {
      this.setActive(idx);
    }
  }

  select(event) {
    this.choose(event.currentTarget);
  }

  choose(option) {
    if (option.disabled) {
      return;
    }
    const { id, label } = option.dataset;

    if (this.multipleValue) {
      this.addBadge(id, label);
      this.selectedIds.add(id);
      this.inputTarget.value = "";
      this.reload("");
      this.inputTarget.focus();
    } else {
      this.inputTarget.value = label;
      this.valueTarget.value = id;
      this.selectedIds = new Set([id]);
      this.close();
    }

    this.toggleClear();
  }

  addBadge(id, label) {
    if (this.selectedIds.has(id)) {
      return;
    }
    // Clone badge tample
    const fragment = this.badgeTemplateTarget.content.cloneNode(true);
    const li = fragment.querySelector("li");
    li.dataset.id = id;
    li.querySelector("input").value = id;
    li.querySelector("span").textContent = label;

    const removeBtn = li.querySelector("button");
    removeBtn.dataset.id = id;
    removeBtn.setAttribute("aria-label", `Remove ${label}`);

    this.selectedTarget.appendChild(fragment);
  }

  remove(event) {
    const { id } = event.currentTarget.dataset;

    this.selectedTarget.querySelector(`li[data-id="${id}"]`)?.remove();
    this.selectedIds.delete(id);

    if (!this.resultsTarget.classList.contains("hidden")) {
      this.reload(this.inputTarget.value.trim());
    }
  }

  clear() {
    this.inputTarget.value = "";

    if (!this.multipleValue) {
      this.valueTarget.value = "";
      this.selectedIds.clear();
    }

    this.close();
    this.toggleClear();
    this.inputTarget.focus();
  }

  toggleClear() {
    if (!this.hasClearTarget) {
      return;
    }

    const hasText = this.inputTarget.value.length > 0;
    const hasValue =
      !this.multipleValue &&
      this.hasValueTarget &&
      this.valueTarget.value.length > 0;

    this.clearTarget.classList.toggle("hidden", !(hasText || hasValue));
  }
}
