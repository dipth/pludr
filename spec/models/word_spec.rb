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
end
