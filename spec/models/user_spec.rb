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

  describe "#legacy_authenticate_by" do
    let(:email_address) { "user@example.com" }
    let(:password) { "qwerty42" }

    context "when a user with the given email address exists" do
      context "when the user has a legacy password" do
        context "when the password is correct" do
          let!(:user) { create(:user, :with_legacy_password_1, email_address: email_address) }

          it "returns the user" do
            expect(User.legacy_authenticate_by(email_address: email_address, password: password)).to eq(user)
          end
        end

        context "when the password is incorrect" do
          let!(:user) { create(:user, :with_legacy_password_2, email_address: email_address) }

          it "returns false" do
            expect(User.legacy_authenticate_by(email_address: email_address, password: password)).to be_falsey
          end
        end
      end

      context "when the user does not have a legacy password" do
        let!(:user) { create(:user, email_address: email_address) }

        it "returns false" do
          expect(User.legacy_authenticate_by(email_address: email_address, password: password)).to be_falsey
        end
      end
    end

    context "when a user with the given email address does not exist" do
      it "returns false" do
        expect(User.legacy_authenticate_by(email_address: email_address, password: password)).to be_falsey
      end
    end
  end

  describe ".ransackable_attributes" do
    it "returns the correct attributes" do
      expect(User.ransackable_attributes).to eq(%w[username name email_address admin created_at updated_at])
    end
  end

  describe ".ransortable_attributes" do
    it "returns the correct attributes" do
      expect(User.ransortable_attributes).to eq(%w[username name email_address admin created_at updated_at])
    end
  end
end
