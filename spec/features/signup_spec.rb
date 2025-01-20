# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Signup", type: :feature do
  let(:user) { build(:user) }

  let(:username) { user.username }
  let(:name) { user.name }
  let(:email_address) { user.email_address }
  let(:password) { user.password }

  it "allows a user to sign up from a link on the landing page" do
    visit root_path
    click_link "Sign up"
    expect(page).to have_text("Create an account")
    fill_in "Username", with: username
    fill_in "Name", with: name
    fill_in "Email address", with: email_address
    fill_in "Password", with: password
    fill_in "Confirm password", with: password
    click_button "Create account"
    expect(page).to have_text("Account created successfully!")
    expect(page).to have_text("Sign out")
  end

  it "shows an error when the username is blank" do
    visit new_user_path
    fill_in "Name", with: name
    fill_in "Email address", with: email_address
    fill_in "Password", with: password
    fill_in "Confirm password", with: password
    click_button "Create account"
    expect(page).to have_text("Username can't be blank")
  end

  it "shows an error when the name is blank" do
    visit new_user_path
    fill_in "Username", with: username
    fill_in "Email address", with: email_address
    fill_in "Password", with: password
    fill_in "Confirm password", with: password
    click_button "Create account"
    expect(page).to have_text("Name can't be blank")
  end

  it "shows an error when the email address is blank" do
    visit new_user_path
    fill_in "Username", with: username
    fill_in "Name", with: name
    fill_in "Password", with: password
    fill_in "Confirm password", with: password
    click_button "Create account"
    expect(page).to have_text("Email address can't be blank")
  end

  it "shows an error when the password is blank" do
    visit new_user_path
    fill_in "Username", with: username
    fill_in "Name", with: name
    fill_in "Email address", with: email_address
    click_button "Create account"
    expect(page).to have_text("Password can't be blank")
  end

  it "shows an error when the password confirmation does not match the password" do
    visit new_user_path
    fill_in "Username", with: username
    fill_in "Name", with: name
    fill_in "Email address", with: email_address
    fill_in "Password", with: password
    fill_in "Confirm password", with: "not-the-same-password"
    click_button "Create account"
    expect(page).to have_text("Password confirmation doesn't match Password")
  end

  it "does not allow a user to sign up with an existing email address" do
    create(:user, email_address: email_address)
    visit new_user_path
    fill_in "Username", with: username
    fill_in "Name", with: name
    fill_in "Email address", with: email_address
    fill_in "Password", with: password
    fill_in "Confirm password", with: password
    click_button "Create account"
    expect(page).to have_text("Email address has already been taken")
  end

  it "does not allow a user to sign up with an existing username" do
    create(:user, username: username)
    visit new_user_path
    fill_in "Username", with: username
    fill_in "Name", with: name
    fill_in "Email address", with: email_address
    fill_in "Password", with: password
    fill_in "Confirm password", with: password
    click_button "Create account"
    expect(page).to have_text("Username has already been taken")
  end

  it "has a working link to the sign in page" do
    visit new_user_path
    click_link "Sign in here"
    expect(page).to have_text("Sign in")
  end
end
