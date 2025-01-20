# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  describe "normalizations" do
    it "strips whitespace from the username" do
      user = build(:user, username: "  username  ")
      expect(user.username).to eq("username")
    end

    it "downcases the email address" do
      user = build(:user, email_address: "USER@EXAMPLE.COM")
      expect(user.email_address).to eq("user@example.com")
    end
  end

  describe "validations" do
    subject { build(:user) }

    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:email_address) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:username).case_insensitive }
    it { should validate_uniqueness_of(:email_address).case_insensitive }
    it { should have_secure_password }
    it { should_not allow_value("invalid email").for(:email_address) }
    it { should_not allow_value("sh").for(:username) } # too short
    it { should_not allow_value("username with spaces").for(:username) } # spaces
    it { should_not allow_value("   ").for(:username) } # just spaces
    it { should_not allow_value("thisusernameiswaaaaaaaaytoolong").for(:username) } # too long
    it { should_not allow_value("short").for(:password) } # too short
  end
end
