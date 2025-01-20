class ApplicationMailer < ActionMailer::Base
  default from: (Rails.application.credentials.dig(:postmark, :from_email) || "from@example.com")
  layout "mailer"
end
