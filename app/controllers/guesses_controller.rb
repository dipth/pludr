# frozen_string_literal: true

# This controller handles the creation of guesses for a game.
class GuessesController < ApplicationController
  before_action :load_game
  before_action :find_game_word
  before_action :find_or_create_guess
  before_action :load_guesses

  # Tries to create a new Guess by looking up the GameWord with the given params[:guess] value
  # and then creating a new Guess with that GameWord for the current user.
  #
  # If the Guess is created successfully, it will be persisted and the user will be redirected to the play page.
  # If the Guess is not created successfully, it will be invalid and the user will be redirected to the play page.
  #
  # The feedback_type and feedback_message are set in the flash to be displayed in the play page.
  def create
    flash[:feedback_type] = feedback_type
    flash[:feedback_message] = feedback_message

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to play_path }
    end
  end

  private

  # Returns the value of the guess from the params.
  # @return [String] The value of the guess from the params.
  def guess_value
    params.require(:guess)
  end

  # Loads the currently active Game.
  # @return [Game] The currently active Game.
  def load_game
    @game = Game.current
  end

  # Finds the matching GameWord for the current game given by the params[:guess] value.
  # @return [GameWord] The matching GameWord for the current game given by the params[:guess] value.
  def find_game_word
    @game_word = @game.game_words.find_by(value: guess_value)
  end

  # Finds or creates a new Guess for the current user and the matching GameWord.
  # If a GameWord was not found (ie. @game_word is nil), the Guess will be invalid and therefore not persisted.
  # @return [Guess] The Guess for the current user and the matching GameWord.
  def find_or_create_guess
    @guess = Current.user.guesses.find_or_create_by(game_word: @game_word)
  end

  # Loads the guesses for the current user for the current game.
  # This is needed to update the list of guesses in alphabetical order when rendering with Turbo.
  # @return [Array<Guess>] The guesses for the current user for the current game.
  def load_guesses
    @guesses = @game.guesses.where(user: Current.user).alphabetical
  end

  # Returns the type of feedback to be displayed to the user depending on the outcome of the Guess.
  # This will either be "correct", "duplicate" or "incorrect".
  # @return [String] The type of feedback to be displayed to the user.
  def feedback_type
    feedback[:type]
  end

  # Returns the feedback message to be displayed to the user depending on the outcome of the Guess.
  # @return [String] The feedback message to be displayed to the user.
  def feedback_message
    feedback[:message]
  end

  # Returns a Hash that represents the type and message of the feedback to be displayed to the user depending on the
  # outcome of the Guess.
  # @return [Hash<String, String>] A Hash that represents the type and message of the feedback to be displayed to the user.
  def feedback
    @feedback ||= if @guess.persisted? && @guess.previously_new_record?
      { type: "correct", message: t("guesses.feedback.correct", word: @guess.value, score: @guess.score) }
    elsif @guess.persisted?
      { type: "duplicate", message: t("guesses.feedback.duplicate", word: @guess.value) }
    else
      { type: "incorrect", message: t("guesses.feedback.incorrect", word: @guess_value) }
    end
  end
end
