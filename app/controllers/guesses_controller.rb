# frozen_string_literal: true

# This controller handles the creation of guesses for a game.
class GuessesController < ApplicationController
  before_action :load_game
  before_action :initialize_game_board
  before_action :find_game_word
  before_action :find_or_create_guess
  before_action :load_guesses

  def create
    respond_to do |format|
      format.turbo_stream
      format.html { render "play/show" }
    end
  end

  private

  def guess_params
    params.require(:guess)
  end

  def load_game
    @game = Game.with_started_state.first
  end

  def initialize_game_board
    @game_board = GameBoard.new(@game)
  end

  def find_game_word
    @game_word = @game.game_words.find_by(value: params[:guess])
  end

  def find_or_create_guess
    @guess = Current.user.guesses.find_or_create_by(game_word: @game_word)
  end

  def load_guesses
    @guesses = @game.guesses.where(user: Current.user).alphabetical
  end
end
