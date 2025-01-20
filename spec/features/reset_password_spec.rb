# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reset password", type: :feature, perform_enqueued_jobs: true do
  let(:user) { create(:user) }

  it "allows a user to reset their password via a link from the sign in page" do
    visit new_session_path

    click_link "Reset password here"
    expect(page).to have_text("Reset password")
    fill_in "Email address", with: user.email_address
    click_button "Email reset instructions"

    expect(page).to have_text("Password reset instructions sent")

    expect(ActionMailer::Base.deliveries.count).to eq(1)
    expect(ActionMailer::Base.deliveries.last.subject).to eq("Reset your password")
    reset_password_link = ActionMailer::Base.deliveries.last.body.encoded.match(/<a href="([^"]+)">this password reset page<\/a>/)[1]
    visit reset_password_link

    expect(page).to have_text("Update your password")
    fill_in "New password", with: "new_password"
    fill_in "Confirm new password", with: "new_password"
    click_button "Save"

    expect(page).to have_text("Password has been reset")

    click_link "Sign in"
    fill_in "Email address", with: user.email_address
    fill_in "Password", with: "new_password"
    click_button "Sign in"
    expect(page).to have_text("Signed in")
  end
end
