# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Guess, type: :model do
  it "has a valid factory" do
    expect(build(:guess)).to be_valid
  end

  describe "validations" do
    it "validates that the game_word association is present" do
      expect(build(:guess, game_word: nil)).to be_invalid
    end

    it "validates that the user association is present" do
      expect(build(:guess, user: nil)).to be_invalid
    end

    it "validates that the game_word is unique for the user" do
      original_guess = create(:guess)
      expect(build(:guess, user: original_guess.user, game_word: original_guess.game_word)).to be_invalid
    end
  end

  describe "associations" do
    it "belongs to a game_word" do
      expect(build(:guess).game_word).to be_a(GameWord)
    end

    it "belongs to a user" do
      expect(build(:guess).user).to be_a(User)
    end
  end

  describe "delegations" do
    it "delegates the value to the game_word" do
      guess = build(:guess)
      expect(guess.value).to eq(guess.game_word.value)
    end

    it "delegates the score to the game_word" do
      guess = build(:guess)
      expect(guess.score).to eq(guess.game_word.score)
    end
  end

  describe "scopes" do
    describe "#alphabetical" do
      it "returns the guesses in alphabetical order" do
        game = create(:game)
        word1 = create(:word, value: "APPLE")
        word2 = create(:word, value: "PEAR")
        word3 = create(:word, value: "BANANA")
        create(:guess, game_word: create(:game_word, game: game, word: word1))
        create(:guess, game_word: create(:game_word, game: game, word: word2))
        create(:guess, game_word: create(:game_word, game: game, word: word3))
        expect(Guess.alphabetical.pluck(:value)).to eq([ "APPLE", "BANANA", "PEAR" ])
      end
    end
  end
end
