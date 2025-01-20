# frozen_string_literal: true

# The User model represents a user of the application.
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  # Normalize the email address to lowercase and strip whitespace.
  # This is techincally not necessary because we're using citext, but it makes lists of users more readable.
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # Normalize the username to strip whitespace.
  normalizes :username, with: ->(e) { e.strip }

  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 30 }, format: { with: /\A[a-zA-Z0-9\-_]+\z/, message: "can only contain letters, numbers, dashes and underscores" }
  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
end
