class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.dig(:postmark, :from_email)
  layout "mailer"
end
