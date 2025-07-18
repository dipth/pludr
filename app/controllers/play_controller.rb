class PlayController < ApplicationController
  def show
    @game = Game.with_started_state.first
    @game_board = GameBoard.new(@game)
    @guesses = @game.guesses.where(user: Current.user).alphabetical
  end
end
