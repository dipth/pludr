# frozen_string_literal: true

# This controller handles the display of the play page which lets the user play the game.
class PlayController < ApplicationController
  # Renders the play page.
  def show
    @game = Game.current
    @game_board = GameBoard.new(@game)
    @guesses = @game.guesses.where(user: Current.user).alphabetical
  end
end
