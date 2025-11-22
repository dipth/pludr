# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GameBoard, type: :model do
  # A B C D E
  # F G H I J
  # K L M N O
  # P Q R S T
  # U V W X A
  let(:game) { build(:game, letters: "ABCDEFGHIJKLMNOPQRSTUVWXA") }
  let(:game_board) { GameBoard.new(game) }

  describe "#game" do
    it "returns the game" do
      expect(game_board.game).to eq(game)
    end
  end

  describe "#all_tiles" do
    it "returns an array of GameTile objects that represent all tiles matching the game's letters" do
      game_board.all_tiles.each_with_index do |tile, index|
        expect(tile).to be_a(GameTile)
        expect(tile.letter).to eq(game.letters[index])
      end
    end
  end

  describe "#board_tiles" do
    it "returns a grouped array of GameTile objects that represent the board tiles" do
      game_board.board_tiles.each_with_index do |row, row_index|
        row.each_with_index do |tile, column_index|
          expect(tile).to be_a(GameTile)
          expect(tile.letter).to eq(game.letters[row_index * Game::GRID_SIZE + column_index])
        end
      end
    end
  end

  describe "#check_word" do
    it "is able to find a word across a single row" do
      word = "ABCDE"
      expect(game_board.check_word(word)).to be_truthy
      expect(game_board.check_word(word.reverse)).to be_truthy
    end

    it "is able to find a word across a single column" do
      word = "AFKPU"
      expect(game_board.check_word(word)).to be_truthy
      expect(game_board.check_word(word.reverse)).to be_truthy
    end

    it "is able to find a word across a connected row and column" do
      word = "ABCDEJOTA"
      expect(game_board.check_word(word)).to be_truthy
      expect(game_board.check_word(word.reverse)).to be_truthy
    end

    it "is able to find a diagonal word" do
      word = "AGMSA"
      expect(game_board.check_word(word)).to be_truthy
      expect(game_board.check_word(word.reverse)).to be_truthy
    end

    it "is able to find a word across a connected diagonal" do
      word = "AGMIE"
      expect(game_board.check_word(word)).to be_truthy
      expect(game_board.check_word(word.reverse)).to be_truthy
    end

    it "is able to find a word that snakes across the board" do
      word = "AFKGCIOSWVU"
      expect(game_board.check_word(word)).to be_truthy
      expect(game_board.check_word(word.reverse)).to be_truthy
    end

    it "is not able to find a word that uses the same tile twice" do
      word = "ABCHB"
      expect(game_board.check_word(word)).to be_falsey
      expect(game_board.check_word(word.reverse)).to be_falsey
    end
  end

  describe "#find_words" do
    let(:word_1) { create(:word, value: "ABCDE") }
    let(:word_2) { create(:word, value: "AFKPU") }
    let(:word_3) { create(:word, value: "NOTFOUND") }
    let(:word_4) { create(:word, value: "AGMSA", deleted_at: 1.minute.ago) }

    before do
      allow(game_board).to receive(:check_word).with(word_1.value).and_return(true)
      allow(game_board).to receive(:check_word).with(word_2.value).and_return(true)
      allow(game_board).to receive(:check_word).with(word_3.value).and_return(false)
      allow(game_board).to receive(:check_word).with(word_4.value).and_return(true)
    end

    it "finds all active words that can be found on the board" do
      expect(game_board.find_words).to match_array([ word_1, word_2 ])
    end
  end
end
