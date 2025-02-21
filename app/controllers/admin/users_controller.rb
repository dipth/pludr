class Admin::UsersController < Admin::BaseController
  def index
    @q = User.ransack(search_params&.to_h || { s: "username asc" })
    @pagy, @users = pagy(@q.result)
  end

  def show
    @user = User.find(params[:id])
    @recent_sessions = @user.sessions.order(created_at: :desc).limit(5)
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: t(".success_notice")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])

    if @user.id != Current.user.id
      @user.destroy
      redirect_to admin_users_path, notice: t(".success_notice")
    else
      redirect_to admin_user_path(@user), alert: t(".cannot_delete_self")
    end
  end

  private

  def search_params
    params.permit(q: [
      :username_cont, :name_cont, :email_address_cont, :admin_eq, :created_at_gteq, :created_at_lteq, :s
    ])[:q]
  end

  def user_params
    params.require(:user).permit(:username, :name, :email_address, :password, :password_confirmation)
  end
end
