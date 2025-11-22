# frozen_string_literal: true

# This class represents the game board and is responsible for checking if a word is valid.
class GameBoard
  # These relative coordinates define the 8 neighbors of a tile.
  NEIGHBOR_RELATIVE_COORDINATES = [
    [ -1, -1 ], [ -1, 0 ], [ -1, 1 ], [ 0, -1 ], [ 0, 1 ], [ 1, -1 ], [ 1, 0 ], [ 1, 1 ]
  ].freeze

  attr_reader :game, :all_tiles, :board_tiles

  # Initialize the game board
  # @param game [Game] The game instance for which the board is being initialized
  # @return [GameBoard] The initialized game board
  def initialize(game)
    @game = game
    prepare_tiles
    connect_tiles
  end

  # Check if a word is valid on the board.
  # Please note that this check disregards whether or not the word is actually in the dictionary,
  # it only checks if the word can be formed on the board.
  # @param word [String] The word to check
  # @return [Boolean] True if the word can be formed on the board, false otherwise
  def check_word(word)
    @all_tiles.each do |tile|
      return true if traverse(word.chars, tile)
    end

    false
  end

  # Finds all valid dictionary words that can be found in the game board.
  # Please note how we use the `candidate_words` scope to limit the number of words that need to be checked.
  # @return [Array<Word>] The array of Words that can be found in the game board
  def find_words
    candidate_words = Word.active.candidate_words(all_letter_pairs)
    candidate_words.select do |word|
      check_word(word.value)
    end
  end

  private

  # Prepare the tiles on the board by initializing a Tile instance for each letter and
  # grouping them into a 2D array
  # @return [nil]
  def prepare_tiles
    @all_tiles = @game.letters.chars.map do |letter|
      GameTile.new(letter)
    end

    @board_tiles = @all_tiles.in_groups_of(Game::GRID_SIZE)

    nil
  end

  # Connect the tiles on the board by finding and adding all neighbors to each tile
  # with a neighbor being a tile that is adjacent to the current tile either orthogonally or diagonally
  # @return [nil]
  def connect_tiles
    @board_tiles.each_with_index do |row, row_index|
      row.each_with_index do |tile, column_index|
        # Check all 8 adjacent positions using relative coordinates
        NEIGHBOR_RELATIVE_COORDINATES.each do |row_offset, col_offset|
          neighbor_row = row_index + row_offset
          neighbor_col = column_index + col_offset

          # Add neighbor if coordinates are within grid bounds
          if (0...Game::GRID_SIZE).cover?(neighbor_row) &&
             (0...Game::GRID_SIZE).cover?(neighbor_col)
            tile.add_neighbor(@board_tiles[neighbor_row][neighbor_col])
          end
        end
      end
    end

    nil
  end

  # Performs a depth-first search to check if a word can be formed on the board
  # @param letters [Array<String>] The remaining letters of the word to check
  # @param current_tile [GameTile] The current tile to check
  # @param visited_tiles [Array<GameTile>] The tiles that have been visited
  # @return [Boolean] True if the word can be formed, false otherwise
  def traverse(letters, current_tile, visited_tiles = [])
    return true if letters.empty?

    return false if visited_tiles.include?(current_tile)

    return false if current_tile.letter != letters.first

    return false unless current_tile.neighbors.any? { |neighbor| traverse(letters[1..-1], neighbor, visited_tiles + [ current_tile ]) }

    true
  end

  # Traverses the board to find all unique two-letter combinations
  # @return [Array<String>] The array of two-letter combinations
  def all_letter_pairs
    @all_tiles.map do |tile|
      tile.neighbors.map do |neighbor|
        "#{tile.letter}#{neighbor.letter}"
      end
    end.flatten.uniq
  end
end
