class UsersController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: I18n.t("users.create.success_notice")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :name, :email_address, :password, :password_confirmation)
  end
end
