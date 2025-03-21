class GameTile
  attr_reader :letter, :value, :neighbors

  def initialize(letter)
    @letter = letter
    @value = Game::LETTERS[letter][:value]
    @vowel = Game::LETTERS[letter][:vowel]
    @neighbors = []
  end

  def vowel?
    @vowel
  end

  def consonant?
    !vowel?
  end

  def add_neighbor(neighbor)
    @neighbors << neighbor
  end
end
