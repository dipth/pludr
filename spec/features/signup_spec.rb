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
    expect(page).to have_text(I18n.t("users.new.title"))
    fill_in I18n.t("activerecord.attributes.user.username"), with: username
    fill_in I18n.t("activerecord.attributes.user.name"), with: name
    fill_in I18n.t("activerecord.attributes.user.email_address"), with: email_address
    fill_in I18n.t("activerecord.attributes.user.password"), with: password
    fill_in I18n.t("activerecord.attributes.user.password_confirmation"), with: password
    click_button I18n.t("users.new.create_account")
    expect(page).to have_text(I18n.t("users.create.success_notice"))
    expect(page).to have_text("Sign out")
  end

  it "shows an error when the username is blank" do
    visit new_user_path
    fill_in I18n.t("activerecord.attributes.user.name"), with: name
    fill_in I18n.t("activerecord.attributes.user.email_address"), with: email_address
    fill_in I18n.t("activerecord.attributes.user.password"), with: password
    fill_in I18n.t("activerecord.attributes.user.password_confirmation"), with: password
    click_button I18n.t("users.new.create_account")
    expect(page).to have_text(I18n.t("errors.messages.blank", attribute: User.human_attribute_name(:username)))
  end

  it "shows an error when the name is blank" do
    visit new_user_path
    fill_in I18n.t("activerecord.attributes.user.username"), with: username
    fill_in I18n.t("activerecord.attributes.user.email_address"), with: email_address
    fill_in I18n.t("activerecord.attributes.user.password"), with: password
    fill_in I18n.t("activerecord.attributes.user.password_confirmation"), with: password
    click_button I18n.t("users.new.create_account")
    expect(page).to have_text(I18n.t("errors.messages.blank", attribute: User.human_attribute_name(:name)))
  end

  it "shows an error when the email address is blank" do
    visit new_user_path
    fill_in I18n.t("activerecord.attributes.user.username"), with: username
    fill_in I18n.t("activerecord.attributes.user.name"), with: name
    fill_in I18n.t("activerecord.attributes.user.password"), with: password
    fill_in I18n.t("activerecord.attributes.user.password_confirmation"), with: password
    click_button I18n.t("users.new.create_account")
    expect(page).to have_text(I18n.t("errors.messages.blank", attribute: User.human_attribute_name(:email_address)))
  end

  it "shows an error when the password is blank" do
    visit new_user_path
    fill_in I18n.t("activerecord.attributes.user.username"), with: username
    fill_in I18n.t("activerecord.attributes.user.name"), with: name
    fill_in I18n.t("activerecord.attributes.user.email_address"), with: email_address
    click_button I18n.t("users.new.create_account")
    expect(page).to have_text(I18n.t("errors.messages.blank", attribute: User.human_attribute_name(:password)))
  end

  it "shows an error when the password confirmation does not match the password" do
    visit new_user_path
    fill_in I18n.t("activerecord.attributes.user.username"), with: username
    fill_in I18n.t("activerecord.attributes.user.name"), with: name
    fill_in I18n.t("activerecord.attributes.user.email_address"), with: email_address
    fill_in I18n.t("activerecord.attributes.user.password"), with: password
    fill_in I18n.t("activerecord.attributes.user.password_confirmation"), with: "not-the-same-password"
    click_button I18n.t("users.new.create_account")
    expect(page).to have_text(I18n.t("errors.messages.confirmation", attribute: User.human_attribute_name(:password)))
  end

  it "does not allow a user to sign up with an existing email address" do
    create(:user, email_address: email_address)
    visit new_user_path
    fill_in I18n.t("activerecord.attributes.user.username"), with: username
    fill_in I18n.t("activerecord.attributes.user.name"), with: name
    fill_in I18n.t("activerecord.attributes.user.email_address"), with: email_address
    fill_in I18n.t("activerecord.attributes.user.password"), with: password
    fill_in I18n.t("activerecord.attributes.user.password_confirmation"), with: password
    click_button I18n.t("users.new.create_account")
    expect(page).to have_text(I18n.t("errors.messages.taken", attribute: User.human_attribute_name(:email_address)))
  end

  it "does not allow a user to sign up with an existing username" do
    create(:user, username: username)
    visit new_user_path
    fill_in I18n.t("activerecord.attributes.user.username"), with: username
    fill_in I18n.t("activerecord.attributes.user.name"), with: name
    fill_in I18n.t("activerecord.attributes.user.email_address"), with: email_address
    fill_in I18n.t("activerecord.attributes.user.password"), with: password
    fill_in I18n.t("activerecord.attributes.user.password_confirmation"), with: password
    click_button I18n.t("users.new.create_account")
    expect(page).to have_text(I18n.t("errors.messages.taken", attribute: User.human_attribute_name(:username)))
  end

  it "has a working link to the sign in page" do
    visit new_user_path
    click_link I18n.t("users.new.sign_in_here")
    expect(page).to have_text("Sign in")
  end
end
