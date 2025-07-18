import { Controller } from "@hotwired/stimulus"
import { sha256 } from "utils/crypto"

export default class extends Controller {
  static targets = ["guessInput"]
  static values = {
    wordHashes: Array,
    salt: String
  }

  reset() {
    this.guessInputTarget.value = ""
    this.resetInvalidGuess()
    this.guessInputTarget.focus()
    this.dispatch('reset')
  }

  handleGuess(event) {
    this.guessInputTarget.value = event.detail.guess
    this.resetInvalidGuess()
  }

  makeGuess(event) {
    event.preventDefault();

    this.guessInputTarget.removeAttribute("aria-invalid")

    const guess = this.guessInputTarget.value.toUpperCase();
    sha256(`${this.saltValue}${guess}`).then(hash => {
      const wordExists = this.wordHashesValue.includes(hash);

      if (!wordExists) {
        this.invalidGuess()
        return;
      }

      // If the word exists, submit the form programmatically
      // Find the closest form and submit it
      const form = this.guessInputTarget.closest("form");
      if (form) form.submit();
    });
  }

  invalidGuess() {
    this.guessInputTarget.setAttribute("aria-invalid", "true")
    this.guessInputTarget.focus()
  }

  resetInvalidGuess() {
    this.guessInputTarget.removeAttribute("aria-invalid")
  }
}
