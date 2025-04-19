# This class represents a tile on the game board.
class GameTile
  attr_reader :letter, :value, :neighbors

  # This method initializes a new GameTile instance.
  # @param letter [String] The letter to initialize the tile with.
  def initialize(letter)
    @letter = letter
    @value = Game::LETTERS[letter][:value]
    @vowel = Game::LETTERS[letter][:vowel]
    @neighbors = []
  end

  # This method checks if the tile represents a vowel.
  # @return [Boolean] True if the tile represents a vowel, false otherwise.
  def vowel?
    @vowel
  end

  # This method checks if the tile represents a consonant.
  # @return [Boolean] True if the tile represents a consonant, false otherwise.
  def consonant?
    !vowel?
  end

  # This method adds a neighbor to the tile.
  # This method should only be called by the GameBoard class.
  # @param neighbor [GameTile] The neighbor to add.
  def add_neighbor(neighbor)
    @neighbors << neighbor
  end
end
