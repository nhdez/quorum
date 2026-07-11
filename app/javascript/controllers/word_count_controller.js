import { Controller } from "@hotwired/stimulus"

// Live word count for a Lexxy editor. Listens for the editor's own
// lexxy:change event and reads its .value (sanitized HTML), parsed down
// to plain text via DOMParser — parsed documents are never attached to
// the page, so nothing in them is ever rendered or executed.
export default class extends Controller {
  static targets = ["editor", "output"]
  static values = { max: Number }

  connect() {
    this.update()
  }

  update() {
    const html = this.editorTarget.value || ""
    const parsed = new DOMParser().parseFromString(html, "text/html")
    const text = (parsed.body.textContent || "").trim()
    const count = text.length ? text.split(/\s+/).length : 0

    const hasMax = this.hasMaxValue && this.maxValue > 0
    this.outputTarget.textContent = hasMax ? `${count} / ${this.maxValue} words` : `${count} word${count === 1 ? "" : "s"}`

    if (hasMax) {
      const overLimit = count > this.maxValue
      this.outputTarget.classList.toggle("text-[#a05050]", overLimit)
      this.outputTarget.classList.toggle("font-bold", overLimit)
    }
  }
}
