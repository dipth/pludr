import { Controller } from "@hotwired/stimulus"
import { sha256 } from "utils/crypto"

export default class extends Controller {
  // ==========================================================================
  // Properties
  // ==========================================================================

  static targets = ["guessInput", "feedback"]
  static values = {
    wordHashes: Array,
    salt: String,
    incorrectMessage: String,
    duplicateMessage: String
  }

  // ==========================================================================
  // Event handlers
  // ==========================================================================

  // Reset the game board by clearing all selected tiles and resetting the guess input
  // and any errors or feedback.
  reset() {
    this.guessInputTarget.value = ""
    this.#resetInvalidGuess()
    this.guessInputTarget.focus()
    this.feedbackTarget.innerHTML = ""
    this.dispatch('reset')
  }

  // Handles a boardChanged event by updating the guess input and resetting
  // any errors or feedback.
  handleBoardChanged(event) {
    this.guessInputTarget.value = event.detail.value
    this.#resetInvalidGuess()
  }

  // Handles a guess event by checking if the guess is valid and submitting the
  // form.
  async makeGuess(event) {
    event.preventDefault();

    this.guessInputTarget.removeAttribute("aria-invalid")

    const guess = this.guessInputTarget.value.toUpperCase();

    // Check if word has already been guessed
    if (this.#checkWordAlreadyGuessed(guess)) {
      this.#showError(this.#interpolateMessage(this.duplicateMessageValue, guess));
      return;
    }

    const wordExists = await this.#checkWordExists(guess);

    if (!wordExists) {
      this.#showError(this.#interpolateMessage(this.incorrectMessageValue, guess));
      return;
    }

    // If the word exists, submit the form programmatically
    // Find the closest form and submit it
    const form = this.guessInputTarget.closest("form");
    if (form) form.requestSubmit();

    this.reset()
  }

  // ==========================================================================
  // Private methods
  // ==========================================================================

  // Checks if a word exists in the game.
  async #checkWordExists(guess) {
    const hash = await sha256(`${this.saltValue}${guess}`);
    return this.wordHashesValue.includes(hash);
  }

  // Checks if a word has already been guessed.
  #checkWordAlreadyGuessed(guess) {
    const guessValueElements = document.querySelectorAll('.guess-value');
    for (const element of guessValueElements) {
      if (element.innerHTML.toUpperCase() === guess) {
        return true;
      }
    }
    return false;
  }

  // Interpolates a message with a word.
  #interpolateMessage(message, word) {
    return message.replace('%{word}', word);
  }

  // Shows an error message.
  #showError(message) {
    this.guessInputTarget.setAttribute("aria-invalid", "true")
    this.feedbackTarget.innerHTML = `<p class='text-red-500 animate-shake'>${message}</p>`
    this.guessInputTarget.focus()
  }

  // Resets the invalid guess state.
  #resetInvalidGuess() {
    this.guessInputTarget.removeAttribute("aria-invalid")
  }
}
