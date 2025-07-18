# frozen_string_literal: true

# This controller handles the creation of guesses for a game.
class GuessesController < ApplicationController
  before_action :set_game

  def create
    @game_word = @game.game_words.find_by(value: params[:guess])

    if @game_word.nil?
      redirect_to play_path, alert: t(".failure_notice")
    else
      @guess = @game.guesses.create(game_word: @game_word, user: Current.user)
      redirect_to play_path, notice: t(".success_notice")
    end
  end

  private

  def guess_params
    params.require(:guess)
  end

  def set_game
    @game = Game.with_started_state.first
  end
end
