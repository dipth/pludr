class Admin::UsersController < Admin::BaseController
  def index
    @q = User.ransack(search_params&.to_h || { s: "username asc" })
    @pagy, @users = pagy(@q.result)
  end

  def show
    @user = User.find(params[:id])
    @recent_sessions = @user.sessions.order(created_at: :asc).limit(5)
  end

  private

  def search_params
    params.permit(q: [
      :username_cont, :name_cont, :email_address_cont, :admin_eq, :created_at_gteq, :created_at_lteq, :s
    ])[:q]
  end
end
