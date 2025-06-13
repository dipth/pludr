# frozen_string_literal: true

# This model represents a game of Pludr.
#
# A game consists of 25 letters, which are used to form a grid of 5x5.
class Game < ApplicationRecord
  include WorkflowActiverecord
  prepend TransitionTransaction

  # These represents the valid letters that can occur in a game:
  LETTERS = YAML.load(File.open("config/letters.yml")).deep_symbolize_keys.stringify_keys

  # These represent the size of the grid:
  GRID_SIZE = 5
  GRID_SIZE_SQUARED = GRID_SIZE * GRID_SIZE

  # These represent the default minimum and maximum number of words in a game, meaning that
  # games with fewer or more words will be rejected. This serves to prevent games that are
  # too easy or too hard from being created.
  DEFAULT_MIN_WORDS = 40
  DEFAULT_MAX_WORDS = 100

  normalizes :letters, with: ->(e) { e.gsub(" ", "").upcase }

  validates :letters, presence: true, length: { is: GRID_SIZE_SQUARED }, format: { with: /\A[#{LETTERS.keys.join}]+\z/ }
  validates :min_words, :max_words, presence: true, numericality: { greater_than_or_equal_to: 1 }

  after_initialize :randomize_letters
  after_initialize :generate_salt
  after_initialize :set_letter_scores
  after_initialize :set_min_and_max_words

  after_commit :trigger_build_game, on: :create, if: -> { building? }

  before_destroy :enforce_destroyable

  has_many :game_words, dependent: :destroy
  has_many :words, through: :game_words

  # This method defines which attributes can be searched via Ransack.
  # @param auth_object [Object] The object that is being authorized. Currently unused.
  # @return [Array<String>] The attributes that can be searched.
  def self.ransackable_attributes(_auth_object = nil)
    %w[id letters game_words_count workflow_state created_at updated_at started_at ended_at]
  end

  # This method defines which attributes can be sorted via Ransack.
  # @param auth_object [Object] The object that is being authorized. Currently unused.
  # @return [Array<String>] The attributes that can be sorted.
  def self.ransortable_attributes(_auth_object = nil)
    %w[id letters game_words_count workflow_state created_at updated_at started_at ended_at]
  end

  workflow do
    # This initial state represents a game that is being generated, meaning that we have yet to find all the words for
    # the game. Once the game is ready, it will transition to the ready state.
    state :building do
      event :ready, transitions_to: :ready
      event :failed, transitions_to: :failed
    end

    # This state represents a game that is ready to be played, meaning that we have found all the words for the game.
    # Once the game is started, it will transition to the started state.
    state :ready do
      event :start, transitions_to: :started
      event :cancel, transitions_to: :canceled
    end

    # This state represents a game that is currently being played, meaning that the players will see this game as the
    # current game. Once the game is ended, it will transition to the ended state.
    state :started do
      event :end, transitions_to: :ended
      event :cancel, transitions_to: :canceled
    end

    # This state represents a game that is ended, meaning that the players will no longer see this game as the current
    # game.
    state :ended

    # This state represents a game that is canceled, meaning that the game will be invisible to the players.
    state :canceled

    # This state represents a game that is failed, meaning that the game will be invisible to the players.
    state :failed

    on_transition do |from, to, triggering_event, *event_args|
      self.started_at = Time.current if to == :started
      self.ended_at = Time.current if %i[ended canceled].include?(to) && from == :started
    end
  end

  # This method returns whether the game can be destroyed.
  # @return [Boolean] Whether the game can be destroyed.
  def destroyable?
    ready? || failed?
  end

  private

  # Randomizes and sets the letters for the game if they are not already set.
  # We use a weighted randomizer to ensure that the letters are distributed as evenly as possible.
  # @return [void]
  def randomize_letters
    return if letters.present?

    weighted_letters = LETTERS.map { |letter, data| [ letter, data[:chance] ] }.to_h
    self.letters = WeightedRandomizer.new(weighted_letters).sample(GRID_SIZE_SQUARED).join
  end

  # Generates and sets a salt for the game if it is not already set.
  # We use the salt to hash words uniquely for this particular game before sending them to the client to ensure that
  # they can be used for validating guesses client-side without exposing the words and thus allowing cheating.
  # If we only hashed the words without a salt, it would be possible to cheat by compiling a pre-hashed dictionary of
  # words.
  # @return [void]
  def generate_salt
    self.salt ||= SecureRandom.hex(16)
  end

  # Sets the letter scores for the game.
  # We do this to ensure that we have a record of what the letter scores were when this game was created, since
  # the scores can change over time.
  # @return [void]
  def set_letter_scores
    self.letter_scores = LETTERS.map { |letter, data| [ letter, data[:value] ] }.to_h
  end

  # Sets the minimum and maximum number of words for the game to the default values if they are not already set.
  # @return [void]
  def set_min_and_max_words
    self.min_words ||= DEFAULT_MIN_WORDS
    self.max_words ||= DEFAULT_MAX_WORDS
  end

  # Triggers the build game job to build the game.
  # @return [void]
  def trigger_build_game
    BuildGameJob.perform_later(id)
  end

  # Enforces the destroyable state of the game.
  # @return [void]
  def enforce_destroyable
    throw :abort unless destroyable?
  end

  # This callback is used when a ready game is started.
  # We use this to ensure that any other running game is ended before starting this one.
  # @return [void]
  def start
    Game.with_started_state.each(&:end!)
  end
end
