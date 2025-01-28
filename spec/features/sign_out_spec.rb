# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sign out", type: :feature do
  let(:user) { create(:user) }

  it "allows a user to sign out" do
    sign_in_as user
    visit root_path
    click_link "Sign out"
    expect(page).to have_text(I18n.t("sessions.destroy.success_notice"))
  end
end
