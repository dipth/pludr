require 'rails_helper'

RSpec.describe GameWord, type: :model do
  it "has a valid factory" do
    expect(build(:game_word)).to be_valid
  end

  describe "validations" do
    it "requires a game" do
      game_word = build(:game_word, game: nil)
      expect(game_word).to be_invalid
    end

    it "requires a word" do
      game_word = build(:game_word, word: nil)
      expect(game_word).to be_invalid
    end

    it "requires a word with a value" do
      game_word = build(:game_word, word: build(:word, value: nil))
      expect(game_word).to be_invalid
    end

    it "does not allow duplicate values for the same game" do
      game_word = create(:game_word)
      duplicate = build(:game_word, game: game_word.game, word: game_word.word)
      expect(duplicate).to be_invalid
    end

    it "allows duplicate values for different games" do
      game_word = create(:game_word)
      duplicate = build(:game_word, game: create(:game), word: game_word.word)
      expect(duplicate).to be_valid
    end
  end

  it "sets the value from the associated word" do
    word = create(:word, value: "TEST")
    game_word = create(:game_word, word: word)
    expect(game_word.value).to eq("TEST")
  end

  it "sets the length from the associated word" do
    word = create(:word, value: "TEST")
    game_word = create(:game_word, word: word)
    expect(game_word.length).to eq(4)
  end

  it "sets the score from the associated word and game" do
    game = create(:game, letter_scores: { "T" => 1, "E" => 2, "S" => 3 })
    word = create(:word, value: "TEST")
    game_word = create(:game_word, word: word, game: game)
    expect(game_word.score).to eq(7)
  end
end
