import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // ==========================================================================
  // Lifecycle events
  // ==========================================================================

  initialize() {
    this.selectedTiles = []
  }

  connect() {
    this.#updateDisabledStates()
  }

  // ==========================================================================
  // Event handlers
  // ==========================================================================

  // Toggle whether a tile is selected or not.
  // When this is called, we check the selected state of the tile.
  // If the tile is selected, we deselect it and all subsequent tiles.
  // If the tile is not selected, and if it can be selected, we select it and
  // all adjacent tiles.
  toggleTile(event) {
    const tile = event.currentTarget
    const isSelected = tile.getAttribute("aria-selected") === "true"

    if (isSelected) {
      this.#deselectTileAndSubsequent(tile)
    } else {
      this.#selectTile(tile)
    }

    this.#updateDisabledStates()
    this.#dispatchBoardChangedEvent()
  }

  // Reset the game board by deselecting all tiles and dispatching an empty
  // guess event.
  resetAllTiles() {
    // Deselect all tiles by deselecting the first tile (which removes all subsequent tiles)
    if (this.selectedTiles.length > 0) {
      this.#deselectTileAndSubsequent(this.selectedTiles[0].element)
    }

    // Update disabled states
    this.#updateDisabledStates()

    // Dispatch empty guess event
    this.#dispatchBoardChangedEvent()
  }

  // ==========================================================================
  // Private methods
  // ==========================================================================

  // Checks if a tile can be selected and if so, marks it as selected.
  #selectTile(tile) {
    const row = parseInt(tile.dataset.row)
    const column = parseInt(tile.dataset.column)

    // Check if this tile can be selected
    if (this.#canSelectTile(row, column)) {
      tile.setAttribute("aria-selected", "true")
      this.selectedTiles.push({ element: tile, row, column })
    }
  }

  // Deselects a tile and all other tiles that were selected after it.
  #deselectTileAndSubsequent(tile) {
    const tileIndex = this.selectedTiles.findIndex(t => t.element === tile)

    if (tileIndex !== -1) {
      // Remove this tile and all subsequent tiles
      const tilesToRemove = this.selectedTiles.slice(tileIndex)

      tilesToRemove.forEach(t => {
        t.element.setAttribute("aria-selected", "false")
      })

      this.selectedTiles = this.selectedTiles.slice(0, tileIndex)
    }
  }

  // Checks if a tile can be selected.
  #canSelectTile(row, column) {
    // If no tiles are selected, any tile can be selected
    if (this.selectedTiles.length === 0) {
      return true
    }

    // Check if the tile is adjacent to the last selected tile
    const lastSelected = this.selectedTiles[this.selectedTiles.length - 1]
    return this.#isAdjacent(lastSelected.row, lastSelected.column, row, column)
  }

  // Checks if two tiles are adjacent.
  #isAdjacent(row1, col1, row2, col2) {
    // Check if tiles are adjacent (orthogonally or diagonally)
    const rowDiff = Math.abs(row1 - row2)
    const colDiff = Math.abs(col1 - col2)

    // Adjacent means difference of 0 or 1 in both row and column
    // (but not both 0, which would be the same tile)
    return rowDiff <= 1 && colDiff <= 1 && (rowDiff !== 0 || colDiff !== 0)
  }

  // Updates the disabled states of the tiles.
  // This serves to show the user which tiles are selectable based on the
  // current state of the game board.
  #updateDisabledStates() {
    const allTiles = this.element.querySelectorAll('[data-action*="game-board#toggleTile"]')

    allTiles.forEach(tile => {
      const row = parseInt(tile.dataset.row)
      const column = parseInt(tile.dataset.column)
      const isSelected = tile.getAttribute("aria-selected") === "true"

      if (isSelected) {
        // Selected tiles should not be disabled
        tile.setAttribute("aria-disabled", "false")
      } else if (this.selectedTiles.length === 0) {
        // When no tiles are selected, no tiles should be disabled
        tile.removeAttribute("aria-disabled")
      } else {
        // Check if this tile is selectable (adjacent to last selected)
        const isSelectable = this.#canSelectTile(row, column)
        tile.setAttribute("aria-disabled", isSelectable ? "false" : "true")
      }
    })
  }

  // Dispatches a boardChanged event with the selected tiles.
  #dispatchBoardChangedEvent() {
    const value = this.selectedTiles.map(tile => tile.element.dataset.letter).join('')
    this.dispatch('boardChanged', { detail: { value } })
  }
}
