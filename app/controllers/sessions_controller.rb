class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  def create
    user = User.legacy_authenticate_by(email_address: params[:email_address], password: params[:password])
    user ||= User.authenticate_by(params.permit(:email_address, :password))

    if user
      start_new_session_for user
      redirect_to after_authentication_url, notice: I18n.t("sessions.create.success_notice")
    else
      redirect_to new_session_path, alert: I18n.t("sessions.create.error_alert")
    end
  end

  def destroy
    terminate_session
    clear_site_data
    redirect_to root_path, notice: I18n.t("sessions.destroy.success_notice")
  end
end
