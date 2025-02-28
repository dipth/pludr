# frozen_string_literal: true

# The Word model represents a word used in games.
class Word < ApplicationRecord
  normalizes :value, with: ->(e) { e.strip.upcase }

  validates :value, presence: true, uniqueness: true, length: { minimum: 4 }

  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

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
end
