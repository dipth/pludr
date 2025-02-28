# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Word, type: :model do
  it "has a valid factory" do
    expect(build(:word)).to be_valid
  end

  describe "normalizations" do
    it "strips whitespace from the value and upcases it" do
      word = build(:word, value: "  word  ")
      expect(word.value).to eq("WORD")
    end
  end

  describe "validations" do
    subject { build(:word) }

    it { should validate_presence_of(:value) }
    it { should validate_uniqueness_of(:value).case_insensitive }
    it { should validate_length_of(:value).is_at_least(4) }

    describe "of the value format" do
      it "does not allow numbers" do
        expect(build(:word, value: "test123")).not_to be_valid
      end

      it "does not allow special characters" do
        expect(build(:word, value: "test-_!@#")).not_to be_valid
      end

      it "does not allow characters with accents" do
        expect(build(:word, value: "tést")).not_to be_valid
      end

      it "does allow the letters æ, ø and å" do
        expect(build(:word, value: "testæøå")).to be_valid
      end
    end
  end

  describe ".ransackable_attributes" do
    it "returns the correct attributes" do
      expect(Word.ransackable_attributes).to eq(%w[value created_at updated_at deleted_at])
    end
  end

  describe ".ransortable_attributes" do
    it "returns the correct attributes" do
      expect(Word.ransortable_attributes).to eq(%w[value created_at updated_at deleted_at])
    end
  end

  describe "#deleted?" do
    it "returns true if the word has been deleted" do
      word = create(:word, deleted_at: Time.current)
      expect(word.deleted?).to be_truthy
    end

    it "returns false if the word has not been deleted" do
      word = create(:word)
      expect(word.deleted?).to be_falsey
    end
  end

  describe "#delete!" do
    it "soft-deletes the word by setting the deleted_at attribute to the current time" do
      word = create(:word)
      word.delete!
      expect(word.reload.deleted_at).to be_within(3.seconds).of(Time.current)
    end

    it "does not touch the deleted_at attribute of already deleted words" do
      deleted_at = 1.day.ago
      word = create(:word, deleted_at: deleted_at)
      word.delete!
      expect(word.reload.deleted_at).to be_within(1.second).of(deleted_at)
    end
  end

  describe "#restore!" do
    it "restores the word by setting the deleted_at attribute to nil" do
      word = create(:word, deleted_at: 1.day.ago)
      word.restore!
      expect(word.reload.deleted_at).to be_nil
    end
  end
end
