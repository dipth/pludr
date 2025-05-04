require 'rails_helper'

RSpec.describe BuildGameJob, type: :job do
  let(:game) { create(:game, state, min_words: 2, max_words: 3) }
  let(:game_board) { instance_double(GameBoard) }
  let(:words) { create_list(:word, 3) }

  before do
    allow(Game).to receive(:find).with(game.id).and_return(game)
    allow(GameBoard).to receive(:new).with(game).and_return(game_board)
    allow(game_board).to receive(:find_words).and_return(words)
  end

  describe "#perform" do
    context "for a game that is in the building state" do
      let(:state) { :building }

      it "creates a GameWord for each found word in the game" do
        expect { subject.perform(game.id) }.to change(game.game_words, :count).by(words.size)
      end

      it "sets the game to the ready state" do
        subject.perform(game.id)
        expect(game.ready?).to be_truthy
      end

      context "when the number of found words are less than the minimum number of words" do
        let(:words) { create_list(:word, 1) }

        it "sets the game to the failed state" do
          subject.perform(game.id)
          expect(game.failed?).to be_truthy
        end
      end

      context "when the number of found words are greater than the maximum number of words" do
        let(:words) { create_list(:word, 4) }

        it "sets the game to the failed state" do
          subject.perform(game.id)
          expect(game.failed?).to be_truthy
        end
      end
    end

    Game.workflow_spec.states.keys.excluding(:building).each do |state|
      context "for a game that is in the #{state} state" do
        let(:state) { state }

        it "does not create any GameWords" do
          expect { subject.perform(game.id) }.not_to change(GameWord, :count)
        end
      end
    end
  end
end
