import { Controller } from "@hotwired/stimulus"

// Generic drag-to-reorder list. Each item element needs data-sortable-target="item"
// and data-id="<record id>". On drop, PATCHes { ids: [...] } (new order) to urlValue.
export default class extends Controller {
  static targets = ["item"]
  static values = { url: String }

  connect() {
    this.itemTargets.forEach((item) => {
      item.setAttribute("draggable", "true")
    })
  }

  dragStart(event) {
    this.dragged = event.currentTarget
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", "")
  }

  dragOver(event) {
    event.preventDefault()
    const target = event.currentTarget
    if (!this.dragged || target === this.dragged) return

    const rect = target.getBoundingClientRect()
    const before = event.clientY < rect.top + rect.height / 2
    target.parentNode.insertBefore(this.dragged, before ? target : target.nextSibling)
  }

  drop(event) {
    event.preventDefault()
    this.persist()
  }

  dragEnd() {
    this.dragged = null
  }

  persist() {
    const ids = this.itemTargets.map((item) => item.dataset.id)

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        Accept: "application/json"
      },
      body: JSON.stringify({ ids })
    })
  }
}
