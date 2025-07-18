# frozen_string_literal: true

# This model represents a word that is part of a game.
class GameWord < ApplicationRecord
  belongs_to :game, counter_cache: true
  belongs_to :word
  has_many :guesses, dependent: :destroy

  validates :game, presence: true
  validates :word, presence: true
  validates :value, presence: true, uniqueness: { scope: :game_id }

  before_validation :set_value_and_hashed_value
  before_validation :calculate_length_and_score

  private

  # Sets the value from the associated word and calculates the hashed value.
  # @return [void]
  def set_value_and_hashed_value
    return if word.blank? || game.blank?

    self.value = word.value
    self.hashed_value = Digest::SHA256.hexdigest("#{game.salt}#{value}")
  end

  # Calculates the length and score of the word using the game's letter scores.
  # @return [void]
  def calculate_length_and_score
    return if value.blank?

    self.length = value.length
    self.score = value.chars.sum { |char| game.letter_scores[char] }
  end
end
