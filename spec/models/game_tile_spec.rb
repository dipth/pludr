# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GameTile, type: :model do
  describe "#letter" do
    it "returns the letter represented by the tile" do
      tile = GameTile.new("A")
      expect(tile.letter).to eq("A")
    end
  end

  describe "#value" do
    it "returns the value of the tile" do
      tile = GameTile.new("C")
      expect(tile.value).to eq(5)
    end
  end

  describe "#vowel?" do
    it "returns true if the letter is a vowel" do
      tile = GameTile.new("A")
      expect(tile.vowel?).to be_truthy
    end

    it "returns false if the letter is not a vowel" do
      tile = GameTile.new("B")
      expect(tile.vowel?).to be_falsey
    end

    it "correctly considers danish vowels as vowels" do
      tile = GameTile.new("Æ")
      expect(tile.vowel?).to be_truthy
    end
  end

  describe "#consonant?" do
    it "returns true if the letter is a consonant" do
      tile = GameTile.new("B")
      expect(tile.consonant?).to be_truthy
    end

    it "returns false if the letter is not a consonant" do
      tile = GameTile.new("A")
      expect(tile.consonant?).to be_falsey
    end
  end
end
