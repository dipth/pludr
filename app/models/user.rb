# frozen_string_literal: true

# The User model represents a user of the application.
class User < ApplicationRecord
  LEGACY_PASSWORD_STRETCHES = 20

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :guesses, dependent: :destroy

  # Normalize the email address to lowercase and strip whitespace.
  # This is techincally not necessary because we're using citext, but it makes lists of users more readable.
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # Normalize the username to strip whitespace.
  normalizes :username, with: ->(e) { e.strip }

  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 30 }, format: { with: /\A[a-zA-Z0-9\-_]+\z/ }
  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  # This method can be used to authenticate users that were created with a legacy password.
  # @param email_address [String] The email address of the user to authenticate.
  # @param password [String] The password to authenticate with.
  # @return [User, false] The user if the authentication is successful, or false if it is not.
  def self.legacy_authenticate_by(email_address:, password:)
    user = User.find_by(email_address: email_address)

    return false unless user && user.password_digest.match?(/^LEGACY\./)

    salt = user.password_digest.split(".").last
    salted_password = password + salt
    input_digest = LEGACY_PASSWORD_STRETCHES.times.inject(salted_password) { |digest, _| Digest::SHA512.hexdigest(digest) }
    source_digest = user.password_digest.split(".").second

    return user if input_digest == source_digest

    false
  end

  # This method defines which attributes can be searched via Ransack.
  # @param auth_object [Object] The object that is being authorized. Currently unused.
  # @return [Array<String>] The attributes that can be searched.
  def self.ransackable_attributes(_auth_object = nil)
    %w[username name email_address admin created_at updated_at]
  end

  # This method defines which attributes can be sorted via Ransack.
  # @param auth_object [Object] The object that is being authorized. Currently unused.
  # @return [Array<String>] The attributes that can be sorted.
  def self.ransortable_attributes(_auth_object = nil)
    %w[username name email_address admin created_at updated_at]
  end
end
