# frozen_string_literal: true

# This model represents a guess made by a user in a game.
class Guess < ApplicationRecord
  belongs_to :game_word
  belongs_to :user

  validates :game_word, presence: true
  validates :user, presence: true
  validates :game_word, uniqueness: { scope: [ :user_id ] }
end
