# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sign out", type: :feature do
  let(:user) { create(:user) }

  it "allows a user to sign out" do
    sign_in_as user
    visit root_path
    click_link "Sign out"

    # Check if the redirect worked and notice is visible
    if page.has_text?(I18n.t("sessions.destroy.success_notice"), wait: 5)
      expect(page).to have_text(I18n.t("sessions.destroy.success_notice"))
    end
  end
end
