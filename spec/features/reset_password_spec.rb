# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reset password", type: :feature, perform_enqueued_jobs: true do
  let(:user) { create(:user) }

  it "allows a user to reset their password via a link from the sign in page" do
    visit new_session_path

    click_link I18n.t("sessions.new.reset_password_here")
    expect(page).to have_text(I18n.t("passwords.new.title"))
    fill_in "Email address", with: user.email_address
    click_button I18n.t("passwords.new.email_reset_instructions_button")

    expect(page).to have_text(I18n.t("passwords.create.success_notice"))

    expect(ActionMailer::Base.deliveries.count).to eq(1)
    expect(ActionMailer::Base.deliveries.last.subject).to eq(I18n.t("passwords_mailer.reset.subject"))

    # Extract the reset password link from the email
    email = ActionMailer::Base.deliveries.last
    html_part = email.parts.find { |p| p.content_type.match(/text\/html/) }.body.raw_source
    doc = Nokogiri::HTML(html_part)
    reset_password_link = doc.at_css('a')['href'].gsub("http://www.example.com", Capybara.app_host)

    visit reset_password_link

    expect(page).to have_text(I18n.t("passwords.edit.title"))
    fill_in :password, with: "new_password"
    fill_in :password_confirmation, with: "new_password"
    click_button I18n.t("passwords.edit.save_button")

    expect(page).to have_text(I18n.t("passwords.update.success_notice"))

    click_link "Sign in"
    fill_in :email_address, with: user.email_address
    fill_in :password, with: "new_password"
    click_button I18n.t("sessions.new.sign_in")
    expect(page).to have_text(I18n.t("sessions.create.success_notice"))
  end
end
