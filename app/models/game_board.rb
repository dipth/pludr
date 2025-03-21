class GameBoard
  def initialize(game)
    @game = game
    prepare_tiles
    connect_tiles
  end

  def check_word(word)
    @all_tiles.each do |tile|
      return true if traverse(word.chars, tile)
    end

    false
  end

  private

  def prepare_tiles
    @all_tiles = @game.letters.chars.map do |letter|
      GameTile.new(letter)
    end

    @board_tiles = @all_tiles.in_groups_of(Game::GRID_SIZE)
  end

  def connect_tiles
    @board_tiles.each_with_index do |row, row_index|
      row.each_with_index do |tile, column_index|
        # North-West
        tile.add_neighbor(@board_tiles[row_index - 1][column_index - 1]) if row_index > 0 && column_index > 0
        # North
        tile.add_neighbor(@board_tiles[row_index - 1][column_index]) if row_index > 0
        # North-East
        tile.add_neighbor(@board_tiles[row_index - 1][column_index + 1]) if row_index > 0 && column_index < Game::GRID_SIZE - 1
        # West
        tile.add_neighbor(@board_tiles[row_index][column_index - 1]) if column_index > 0
        # East
        tile.add_neighbor(@board_tiles[row_index][column_index + 1]) if column_index < Game::GRID_SIZE - 1
        # South-West
        tile.add_neighbor(@board_tiles[row_index + 1][column_index - 1]) if row_index < Game::GRID_SIZE - 1 && column_index > 0
        # South
        tile.add_neighbor(@board_tiles[row_index + 1][column_index]) if row_index < Game::GRID_SIZE - 1
        # South-East
        tile.add_neighbor(@board_tiles[row_index + 1][column_index + 1]) if row_index < Game::GRID_SIZE - 1 && column_index < Game::GRID_SIZE - 1
      end
    end
  end

  def traverse(letters, current_tile, visited_tiles = [])
    return true if letters.empty?

    return false if visited_tiles.include?(current_tile)

    return false if current_tile.letter != letters.first

    return false unless current_tile.neighbors.any? { |neighbor| traverse(letters[1..-1], neighbor, visited_tiles + [ current_tile ]) }

    true
  end
end
