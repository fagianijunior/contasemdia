import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "transactionType", "category", "origin", "installments", "wallet", "creditCard",
    "walletSelect", "creditCardSelect", "dueDate"
  ]

  connect() {
    this.updateCategories()
    this.updateOrigin()
    this.updateDueDate()
  }

  updateOrigin() {
    const origin = this.originTargets.find((radio) => radio.checked)?.value
    const isWallet = origin === "wallet"

    this.toggleTarget(this.walletTarget, this.walletSelectTarget, isWallet)
    this.toggleTarget(this.creditCardTarget, this.creditCardSelectTarget, !isWallet)
    this.installmentsTarget.hidden = isWallet

    if (isWallet) {
      this.creditCardSelectTarget.value = ""
    } else {
      this.walletSelectTarget.value = ""
    }
  }

  toggleTarget(container, select, visible) {
    container.hidden = !visible
    select.disabled = !visible
  }

  updateDueDate() {
    const selectedCard = this.creditCardSelectTarget.selectedOptions[0]
    const dueDay = Number(selectedCard?.dataset.dueDay)

    if (!dueDay || this.creditCardSelectTarget.disabled) {
      return
    }

    const today = new Date()
    let year = today.getFullYear()
    let month = today.getMonth()

    if (today.getDate() > dueDay) {
      month += 1
      if (month > 11) {
        month = 0
        year += 1
      }
    }

    const dueDate = new Date(year, month, dueDay)
    const formattedDate = [
      dueDate.getFullYear(),
      String(dueDate.getMonth() + 1).padStart(2, "0"),
      String(dueDate.getDate()).padStart(2, "0")
    ].join("-")

    this.dueDateTarget.value = formattedDate
  }

  updateCategories() {
    const type = this.transactionTypeTarget.value
    const categorySelect = this.categoryTarget

    let hasValidOption = false

    for (const option of categorySelect.options) {
      const isBlankOption = option.value === ""
      const matchesType = !type || isBlankOption || option.dataset.categoryType === type

      option.hidden = !matchesType
      option.disabled = !matchesType

      if (matchesType && option.value === categorySelect.value) {
        hasValidOption = true
      }
    }

    if (type && !hasValidOption) {
      categorySelect.value = ""
    }
  }
}
