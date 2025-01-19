# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sign in", type: :feature do
  let(:email_address) { Faker::Internet.email }
  let(:password) { Faker::Internet.password }

  it "allows a user to sign in from a link on the landing page" do
    create(:user, email_address: email_address, password: password, password_confirmation: password)
    visit root_path
    click_link "Sign in"
    expect(page).to have_text("Sign in")
    fill_in "Email address", with: email_address
    fill_in "Password", with: password
    click_button "Sign in"
    expect(page).to have_text("Signed in")
  end

  it "shows an error when the email address or password is incorrect" do
    visit new_session_path
    fill_in "Email address", with: email_address
    fill_in "Password", with: password
    click_button "Sign in"
    expect(page).to have_text("Try another email address or password.")
  end
end
