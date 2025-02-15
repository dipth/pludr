class Admin::BaseController < ApplicationController
  layout "admin/application"

  before_action :require_admin

  private

  def require_admin
    unless Current.user.admin?
      flash[:alert] = "You are not authorized to access this page."
      redirect_to root_path
    end
  end
end
