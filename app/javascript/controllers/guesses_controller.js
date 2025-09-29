import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // ==========================================================================
  // Lifecycle
  // ==========================================================================

  connect() {
    // Set up MutationObserver to watch for changes in the guesses container
    this.#setupMutationObserver()

    // Also set up a periodic check as a fallback to detect highlighted guesses
    this.#setupPeriodicCheck()
  }

  disconnect() {
    // Disconnect MutationObserver
    if (this.mutationObserver) {
      this.mutationObserver.disconnect()
    }

    // Clear periodic check
    if (this.periodicCheckInterval) {
      clearInterval(this.periodicCheckInterval)
    }
  }

  // ==========================================================================
  // Private methods
  // ==========================================================================

  // Sets up a periodic check for highlighted guesses as a fallback
  #setupPeriodicCheck() {
    this.periodicCheckInterval = setInterval(() => {
      const highlightedGuess = document.querySelector('[aria-selected="true"]')

      // Check if we have a new highlighted guess (different from the last one)
      if (highlightedGuess && highlightedGuess !== this.lastHighlightedGuess) {
        this.lastHighlightedGuess = highlightedGuess
        this.#scrollToHighlightedGuess()
      } else if (!highlightedGuess && this.lastHighlightedGuess) {
        this.lastHighlightedGuess = null
      }
    }, 500) // Check every 500ms
  }

  // Sets up a MutationObserver to watch for changes in the guesses container
  #setupMutationObserver() {
    const guessesContainer = document.getElementById('guesses-container')
    if (!guessesContainer) {
      // Retry after a short delay if container not found yet
      setTimeout(() => this.#setupMutationObserver(), 100)
      return
    }

    this.mutationObserver = new MutationObserver((mutations) => {
      let shouldScroll = false

      mutations.forEach((mutation) => {
        if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
          shouldScroll = true
        } else if (mutation.type === 'attributes' && mutation.attributeName === 'aria-selected') {
          shouldScroll = true
        }
      })

      if (shouldScroll) {
        this.#scrollToHighlightedGuess()
      }
    })

    this.mutationObserver.observe(guessesContainer, {
      childList: true,
      subtree: true,
      attributes: true,
      attributeFilter: ['aria-selected']
    })
  }


  // Scrolls to the highlighted guess if one exists
  #scrollToHighlightedGuess() {
    const highlightedGuess = document.querySelector('[aria-selected="true"]')
    const guessesContainer = document.getElementById('guesses-container')

    if (highlightedGuess && guessesContainer) {
      // Scroll the highlighted guess into view with smooth animation
      highlightedGuess.scrollIntoView({
        behavior: 'smooth',
        block: 'center',
        inline: 'nearest'
      })
    }
  }
}
