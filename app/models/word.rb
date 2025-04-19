# frozen_string_literal: true

# The Word model represents a word used in games.
class Word < ApplicationRecord
  normalizes :value, with: ->(e) { e.strip.upcase }

  validates :value, presence: true, uniqueness: true, length: { minimum: 4 },
                    format: { with: /\A[a-zæøåÆØÅ]+\z/i }

  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

  # This scope finds all words that only contain letter pairs covered by the given array of letter pairs.
  # This is helpful to limit the number of words that need to be checked for validity in a game.
  # @param letter_pairs [Array<String>] The array of letter pairs to check against
  scope :candidate_words, ->(letter_pairs) { where("letter_pairs <@ ARRAY[?]::varchar[]", letter_pairs) }

  before_validation :set_letter_pairs

  # This method defines which attributes can be searched via Ransack.
  # @param auth_object [Object] The object that is being authorized. Currently unused.
  # @return [Array<String>] The attributes that can be searched.
  def self.ransackable_attributes(_auth_object = nil)
    %w[value created_at updated_at deleted_at]
  end

  # This method defines which attributes can be sorted via Ransack.
  # @param auth_object [Object] The object that is being authorized. Currently unused.
  # @return [Array<String>] The attributes that can be sorted.
  def self.ransortable_attributes(_auth_object = nil)
    %w[value created_at updated_at deleted_at]
  end

  # This method checks if the word has been deleted.
  # @return [Boolean] True if the word has been deleted, false otherwise.
  def deleted?
    deleted_at.present?
  end

  # This method deletes the word.
  # @return [void]
  def delete!
    update(deleted_at: Time.current) unless deleted?
  end

  # This method restores the word.
  # @return [void]
  def restore!
    update(deleted_at: nil) if deleted?
  end

  private

  # This method sets the letter_pairs value of the word by taking the value and splitting it into all
  # two letter combinations, for instance "HELLO" -> ["HE", "EL", "LL", "LO"]
  # @return [void]
  def set_letter_pairs
    return if value.blank?

    self.letter_pairs = value.chars.each_cons(2).map(&:join).to_a
  end
end
