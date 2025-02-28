class Admin::WordsController < Admin::BaseController
  before_action :find_word, only: [ :show, :edit, :update, :destroy, :restore ]
  before_action :protect_deleted_words, only: [ :edit, :update ]

  def index
    @q = Word.ransack(search_params&.to_h || { s: "value asc" })
    @pagy, @words = pagy(@q.result)
  end

  def show
  end

  def new
    @word = Word.new
  end

  def create
    @word = Word.new(word_params)
    if @word.save
      redirect_to admin_word_path(@word), notice: t(".success_notice")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @word.update(word_params)
      redirect_to admin_word_path(@word), notice: t(".success_notice")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @word.delete!
    redirect_to admin_word_path(@word), notice: t(".success_notice")
  end

  def restore
    @word.restore!
    redirect_to admin_word_path(@word), notice: t(".success_notice")
  end

  private

  def search_params
    params.permit(q: [
      :value_cont, :created_at_gteq, :created_at_lteq, :deleted_at_null, :s
    ])[:q]
  end

  def word_params
    params.require(:word).permit(:value)
  end

  def find_word
    @word = Word.find(params[:id])
  end

  # We want to protect deleted words from being edited or updated
  def protect_deleted_words
    if @word.deleted?
      redirect_to admin_word_path(@word), alert: t("admin.words.deleted_words_are_protected")
    end
  end
end
