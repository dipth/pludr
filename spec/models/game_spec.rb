# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game, type: :model do
  it "has a valid factory" do
    expect(build(:game)).to be_valid
  end

  it "automatically generates a salt" do
    expect(build(:game).salt).to be_present
  end

  it "never overwrites an existing salt" do
    game = create(:game)
    old_salt = game.salt
    expect(Game.find(game.id).salt).to eq(old_salt)
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

      it "can transition to canceled" do
        game.cancel!
        expect(game.current_state).to eq("canceled")
      end

      context "when transitioning to the started state" do
        it "sets the started_at attribute to the current time" do
          game.start!
          expect(game.started_at).to be_within(1.second).of(Time.current)
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
    end

    context "for a canceled game" do
      let(:game) { create(:game, :canceled) }

      it "cannot transition to started" do
        expect { game.start! }.to raise_error(Workflow::NoTransitionAllowed)
      end

      it "cannot transition to ended" do
        expect { game.end! }.to raise_error(Workflow::NoTransitionAllowed)
      end
    end
  end

  describe "#randomize_letters" do
    Game.workflow_spec.states.keys.excluding(:building).each do |state|
      context "when the game is in the #{state} state" do
        let(:game) { create(:game, state) }

        it "raises an error" do
          expect { game.randomize_letters }.to raise_error("Cannot randomize letters for a game that is not in the building state")
        end
      end
    end

    context "when the game is in the building state" do
      let(:game) { build(:game, :building) }

      it "randomizes the letters" do
        game.randomize_letters
        expect(game.letters).to be_present
        expect(game.letters.length).to eq(Game::GRID_SIZE_SQUARED)
      end

      it "uses a weighted randomizer to randomize the letters" do
        allow(WeightedRandomizer).to receive(:new).and_return(double(sample: [ "A" ] * 25))
        game.randomize_letters
        expect(game.letters).to eq("A" * 25)
      end
    end
  end
end
