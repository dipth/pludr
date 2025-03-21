# frozen_string_literal: true

# This model represents a game of Pludr.
#
# A game consists of 25 letters, which are used to form a grid of 5x5.
class Game < ApplicationRecord
  include WorkflowActiverecord

  # These represents the valid letters that can occur in a game:
  LETTERS = YAML.load(File.open("config/letters.yml")).deep_symbolize_keys.stringify_keys

  # These represent the size of the grid:
  GRID_SIZE = 5
  GRID_SIZE_SQUARED = GRID_SIZE * GRID_SIZE

  normalizes :letters, with: ->(e) { e.gsub(" ", "").upcase }

  validates :letters, presence: true, length: { is: GRID_SIZE_SQUARED }, format: { with: /\A[#{LETTERS.keys.join}]+\z/ }

  after_initialize :generate_salt

  workflow do
    # This initial state represents a game that is being generated, meaning that we have yet to find all the words for
    # the game. Once the game is ready, it will transition to the ready state.
    state :building do
      event :ready, transitions_to: :ready
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

    on_transition do |from, to, triggering_event, *event_args|
      self.started_at = Time.current if to == :started
      self.ended_at = Time.current if %i[ended canceled].include?(to) && from == :started
    end
  end

  # Randomizes the letters for the game by picking a weighted random letter for each position in the grid.
  # This can only be done if the game is in the building state.
  # @return [String] The randomly chosen letters.
  def randomize_letters
    raise "Cannot randomize letters for a game that is not in the building state" unless building?

    weighted_letters = LETTERS.map { |letter, data| [ letter, data[:chance] ] }.to_h
    self.letters = WeightedRandomizer.new(weighted_letters).sample(GRID_SIZE_SQUARED).join
  end

  private

  # Generates and sets a salt for the game if it is not already set.
  # We use the salt to hash words uniquely for this particular game before sending them to the client to ensure that
  # they can be used for validating guesses client-side without exposing the words and thus allowing cheating.
  # If we only hashed the words without a salt, it would be possible to cheat by compiling a pre-hashed dictionary of
  # words.
  # @return [String] The salt for the game.
  def generate_salt
    self.salt ||= SecureRandom.hex(16)
  end
end
