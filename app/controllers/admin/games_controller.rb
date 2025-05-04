class Admin::GamesController < Admin::BaseController
  def index
    @q = Game.ransack(search_params&.to_h || { s: "id desc" })
    @pagy, @games = pagy(@q.result)
  end

  def new
    @game = Game.new
  end

  def create
    @game = Game.new(game_params)
    if @game.save
      redirect_to admin_game_path(@game), notice: t(".success_notice")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @game = Game.find(params[:id])
  end

  def destroy
    @game = Game.find(params[:id])
    if @game.destroy
      redirect_to admin_games_path, notice: t(".success_notice")
    else
      redirect_to admin_game_path(@game), alert: t(".failure_notice")
    end
  end

  private

  def game_params
    params.require(:game).permit(:min_words, :max_words)
  end

  def search_params
    params.permit(q: [
      :id_cont, :letters_cont, :workflow_state_cont, :created_at_gteq, :created_at_lteq, :s
    ])[:q]
  end
end
