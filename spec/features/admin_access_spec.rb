# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin access", type: :feature do
  let(:user) { create(:user, admin: true) }

  before do
    sign_in_as user
  end

  it "allows admins to access the admin dashboard from a link in the navigation bar" do
    visit root_path
    click_link I18n.t("layouts.nav.admin")
    expect(page).to have_content(I18n.t("admin.dashboards.index.title"))
  end

  it "allows admins to navigate back to the main site from the admin dashboard" do
    visit admin_root_path
    click_button user.username
    click_link I18n.t("layouts.admin.nav.back_to_site")
    expect(page).to have_content(I18n.t("layouts.nav.edit_account"))
  end
end
