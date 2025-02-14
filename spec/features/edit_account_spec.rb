# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Edit account", type: :feature do
  let(:user) { create(:user) }

  before do
    sign_in_as user
  end

  it "allows a user to edit their account via a link in the navigation bar" do
    visit root_path
    click_link I18n.t("layouts.nav.edit_account")
    expect(page).to have_content(I18n.t("accounts.edit.title"))

    fill_in I18n.t("activerecord.attributes.user.username"), with: "new_username"
    fill_in I18n.t("activerecord.attributes.user.name"), with: "new_name"
    fill_in I18n.t("activerecord.attributes.user.email_address"), with: "new@example.com"
    fill_in I18n.t("activerecord.attributes.user.password"), with: "new_password"
    fill_in I18n.t("activerecord.attributes.user.password_confirmation"), with: "new_password"
    click_button I18n.t("accounts.edit.update_account")

    expect(page).to have_content(I18n.t("accounts.update.success_notice"))
  end
end
