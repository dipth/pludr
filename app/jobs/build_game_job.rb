class BuildGameJob < ApplicationJob
  queue_as :default

  def perform(game_id)
    @game = Game.find(game_id)

    return unless @game.building?

    @game_board = GameBoard.new(@game)

    find_words!
    create_game_words!
    update_game_state!
  end

  private

  def find_words!
    @words = @game_board.find_words
  end

  def create_game_words!
    @words.each do |word|
      @game.game_words.create!(game: @game, word: word)
    end
  end

  def update_game_state!
    if @game.game_words.size >= @game.min_words && @game.game_words.size <= @game.max_words
      @game.ready!
    else
      @game.failed!
    end
  end
end
