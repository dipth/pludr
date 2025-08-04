# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Play", type: :feature, js: true do
  let(:user) { create(:user) }

  before do
    game = create(:game, :started, letters: "ABCDEFGHIJKLMNOPQRSTUVWXY")
    create(:game_word, game: game, word: create(:word, value: "ABCDE")).update_column(:score, 10)
    create(:game_word, game: game, word: create(:word, value: "AGMSY")).update_column(:score, 20)
    create(:game_word, game: game, word: create(:word, value: "AFLHBG")).update_column(:score, 30)
  end

  it "allows a user to play the game" do
    sign_in_as user
    visit root_path
    click_link I18n.t("layouts.nav.play")
    expect(page).to have_text(I18n.t("play.show.title"))

    click_tiles("A", "B", "C", "D")
    submit_guess!
    expect(page).to have_text(I18n.t("guesses.feedback.incorrect", word: "ABCD"))
    reset_guess!

    click_tiles("A", "B", "C", "D", "E")
    submit_guess!(wait: true)
    expect_correct_guess!("ABCDE", 10)

    click_tiles("A", "B", "C", "D", "E")
    submit_guess!
    expect(page).to have_text(I18n.t("guesses.feedback.duplicate", word: "ABCDE"))
    reset_guess!

    click_tiles("A", "F", "L", "H", "B", "G")
    submit_guess!(wait: true)
    expect_correct_guess!("AFLHBG", 30)

    fill_in "guess", with: "AGMSY"
    submit_guess!(wait: true)
    expect_correct_guess!("AGMSY", 20)
  end

  def click_tile(letter)
    find("div[data-letter='#{letter}']").click
  end

  def click_tiles(*letters)
    letters.each { |letter| click_tile(letter) }
  end

  def submit_guess!(wait: false)
    click_button I18n.t("guesses.form.guess")
    wait_for_turbo_frame("turbo-frame[id='guesses']") if wait
  end

  def reset_guess!
    click_button I18n.t("guesses.form.reset")
  end

  def expect_correct_guess!(word, score)
    # Check that the user received correct feedback:
    expect(page).to have_text(I18n.t("guesses.feedback.correct", word: word, score: score))

    # Check that the guess is displayed as highlighted in the guesses list:
    within "turbo-frame#guesses" do
      within "div[aria-selected='true']" do
        expect(page).to have_text(word)
        expect(page).to have_text(score)
      end
    end
  end
end
