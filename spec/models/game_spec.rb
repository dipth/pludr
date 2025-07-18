# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game, type: :model do
  it "has a valid factory" do
    expect(build(:game)).to be_valid
  end

  describe "initialization" do
    it "automatically generates a salt" do
      expect(build(:game).salt).to be_present
    end

    it "never overwrites an existing salt" do
      game = create(:game)
      old_salt = game.salt
      expect(Game.find(game.id).salt).to eq(old_salt)
    end

    it "randomizes the letters on initialize" do
      game = Game.new
      expect(game.letters).to be_present
      expect(game.letters.length).to eq(Game::GRID_SIZE_SQUARED)
    end

    it "uses a weighted randomizer to randomize the letters" do
      allow(WeightedRandomizer).to receive(:new).and_return(double(sample: [ "A" ] * 25))
      game = Game.new
      expect(game.letters).to eq("A" * 25)
    end

    it "does not randomize the letters if they are already set" do
      game = Game.new(letters: "A" * 25)
      expect(game.letters).to eq("A" * 25)
    end

    it "stores the letter scores on initialize" do
      game = Game.new
      expect(game.letter_scores).to eq(Game::LETTERS.map { |letter, data| [ letter, data[:value] ] }.to_h)
    end

    it "sets min_words to the default value if it is not set" do
      game = Game.new
      expect(game.min_words).to eq(Game::DEFAULT_MIN_WORDS)
    end

    it "does not change min_words if it is set" do
      game = Game.new(min_words: 1)
      expect(game.min_words).to eq(1)
    end

    it "sets max_words to the default value if it is not set" do
      game = Game.new
      expect(game.max_words).to eq(Game::DEFAULT_MAX_WORDS)
    end

    it "does not change max_words if it is set" do
      game = Game.new(max_words: 1)
      expect(game.max_words).to eq(1)
    end
  end

  describe "normalizations" do
    it "it removes spaces from the letters and converts to uppercase" do
      expect(build(:game, letters: "e f g h i j k l m n o p q r s t u v w x y z æ ø å").letters).to eq("EFGHIJKLMNOPQRSTUVWXYZÆØÅ")
    end
  end

  describe "validations" do
    it "requires letters to have 25 characters" do
      expect(build(:game, letters: "A" * 24)).to be_invalid
      expect(build(:game, letters: "A" * 26)).to be_invalid
    end

    it "requires all characters in letters to be any of the valid letters" do
      expect(build(:game, letters: "A" * 24 + "Ü")).to be_invalid
    end

    it "requires min_words to be set" do
      expect(build(:game, min_words: nil)).to be_invalid
    end

    it "requires max_words to be set" do
      expect(build(:game, max_words: nil)).to be_invalid
    end

    it "requires min_words to be greater than or equal to 1" do
      expect(build(:game, min_words: 0)).to be_invalid
    end

    it "requires max_words to be greater than or equal to 1" do
      expect(build(:game, max_words: 0)).to be_invalid
    end

    it "does not allow multiple started games" do
      create(:game, :started)
      expect { create(:game, :started) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "associations" do
    it "has many game_words" do
      expect(build(:game).game_words).to be_a(ActiveRecord::Relation)
    end

    it "has many words through game_words" do
      expect(build(:game).words).to be_a(ActiveRecord::Relation)
    end

    it "has many guesses through game_words" do
      expect(build(:game).guesses).to be_a(ActiveRecord::Relation)
    end
  end

  describe "states" do
    context "for a new game" do
      let(:game) { build(:game) }

      it "starts out in the building state" do
        expect(game.current_state).to eq("building")
      end
    end

    context "for a building game" do
      let(:game) { create(:game, :building) }

      it "can transition to ready" do
        game.ready!
        expect(game.current_state).to eq("ready")
      end

      it "can transition to failed" do
        game.failed!
        expect(game.current_state).to eq("failed")
      end

      it "cannot transition to started" do
        expect { game.start! }.to raise_error(Workflow::NoTransitionAllowed)
      end

      it "cannot transition to ended" do
        expect { game.end! }.to raise_error(Workflow::NoTransitionAllowed)
      end

      it "cannot transition to canceled" do
        expect { game.cancel! }.to raise_error(Workflow::NoTransitionAllowed)
      end
    end

    context "for a ready game" do
      let(:game) { create(:game, :ready) }

      it "can transition to started" do
        game.start!
        expect(game.current_state).to eq("started")
      end

      it "cannot transition to ended" do
        expect { game.end! }.to raise_error(Workflow::NoTransitionAllowed)
      end

      it "cannot transition to failed" do
        expect { game.failed! }.to raise_error(Workflow::NoTransitionAllowed)
      end

      it "can transition to canceled" do
        game.cancel!
        expect(game.current_state).to eq("canceled")
      end

      context "when transitioning to the started state" do
        it "sets the started_at attribute to the current time" do
          game.start!
          expect(game.started_at).to be_within(1.second).of(Time.current)
        end

        it "ends any existing started game" do
          other_game = create(:game, :started)
          game.start!
          expect(other_game.reload.current_state).to eq("ended")
        end
      end

      context "when transitioning to the canceled state" do
        it "does not set the ended_at attribute" do
          game.cancel!
          expect(game.ended_at).to be_nil
        end
      end
    end

    context "for a started game" do
      let(:game) { create(:game, :started) }

      it "can transition to ended" do
        game.end!
        expect(game.current_state).to eq("ended")
      end

      it "can transition to canceled" do
        game.cancel!
        expect(game.current_state).to eq("canceled")
      end

      it "cannot transition to failed" do
        expect { game.failed! }.to raise_error(Workflow::NoTransitionAllowed)
      end

      context "when transitioning to the ended state" do
        let(:game) { create(:game, :started) }

        it "sets the ended_at attribute to the current time" do
          game.end!
          expect(game.ended_at).to be_within(1.second).of(Time.current)
        end
      end

      context "when transitioning to the canceled state" do
        let(:game) { create(:game, :started) }

        it "sets the ended_at attribute to the current time" do
          game.cancel!
          expect(game.ended_at).to be_within(1.second).of(Time.current)
        end
      end
    end

    context "for an ended game" do
      let(:game) { create(:game, :ended) }

      it "cannot transition to started" do
        expect { game.start! }.to raise_error(Workflow::NoTransitionAllowed)
      end

      it "cannot transition to canceled" do
        expect { game.cancel! }.to raise_error(Workflow::NoTransitionAllowed)
      end

      it "cannot transition to failed" do
        expect { game.failed! }.to raise_error(Workflow::NoTransitionAllowed)
      end
    end

    context "for a canceled game" do
      let(:game) { create(:game, :canceled) }

      it "cannot transition to started" do
        expect { game.start! }.to raise_error(Workflow::NoTransitionAllowed)
      end

      it "cannot transition to ended" do
        expect { game.end! }.to raise_error(Workflow::NoTransitionAllowed)
      end

      it "cannot transition to failed" do
        expect { game.failed! }.to raise_error(Workflow::NoTransitionAllowed)
      end
    end
  end

  describe "#current" do
    it "returns the currently active game" do
      game = create(:game, :started)
      expect(Game.current).to eq(game)
    end

    it "returns nil if there is no currently active game" do
      Game.workflow_spec.states.keys.excluding(:started).each do |state|
        create(:game, state)
      end

      expect(Game.current).to be_nil
    end
  end

  describe "#destroyable?" do
    it "returns true if the game is in the ready state" do
      expect(create(:game, :ready).destroyable?).to be_truthy
    end

    it "returns true if the game is in the failed state" do
      expect(create(:game, :failed).destroyable?).to be_truthy
    end

    Game.workflow_spec.states.keys.excluding(:ready, :failed).each do |state|
      it "returns false if the game is in the #{state} state" do
        expect(create(:game, state).destroyable?).to be_falsey
      end
    end
  end

  describe "#destroy" do
    let(:game) { create(:game, workflow_state) }

    # Make sure that the game is created before we run the tests.
    before { game }

    %i[ready failed].each do |state|
      context "when the game is in the #{state} state" do
        let(:workflow_state) { state }

        it "deletes the game" do
          expect { game.destroy }.to change(Game, :count).by(-1)
        end

        it "returns true" do
          expect(game.destroy).to be_truthy
        end
      end
    end

    Game.workflow_spec.states.keys.excluding(:ready, :failed).each do |state|
      context "when the game is in the #{state} state" do
        let(:workflow_state) { state }

        it "does not delete the game" do
          expect { game.destroy }.not_to change(Game, :count)
        end

        it "returns false" do
          expect(game.destroy).to be_falsey
        end
      end
    end
  end
end
