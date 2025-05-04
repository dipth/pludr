require 'rails_helper'

RSpec.describe Admin::GamesController, type: :controller do
  before { sign_in_as(current_user) if current_user }

  describe "GET #index" do
    context "when the current user is an admin" do
      let(:current_user) { create(:user, admin: true) }

      it "renders the index template" do
        get :index
        expect(response).to render_template(:index)
      end

      it "assigns @games" do
        get :index
        expect(assigns(:games)).to be_a(ActiveRecord::Relation)
      end

      it "assigns @pagy" do
        get :index
        expect(assigns(:pagy)).to be_a(Pagy)
      end

      it "assigns @q" do
        get :index
        expect(assigns(:q)).to be_a(Ransack::Search)
      end

      it "allows searching via params[:q]" do
        allow(Game).to receive(:ransack).and_return(double(result: Game.all))
        get :index, params: { q: { letters_cont: "test" } }
        expect(Game).to have_received(:ransack).with(letters_cont: "test")
      end

      it "sorts games descending by id by default" do
        allow(Game).to receive(:ransack).and_return(double(result: Game.all))
        get :index
        expect(Game).to have_received(:ransack).with(s: "id desc")
      end
    end

    context "when the current user is not an admin" do
      let(:current_user) { create(:user) }

      it "redirects to the root path" do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end

    context "when the current user is not signed in" do
      let(:current_user) { nil }

      it "redirects to the sign in page" do
        get :index
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "GET #show" do
    let(:game) { create(:game) }

    context "when the current user is an admin" do
      let(:current_user) { create(:user, admin: true) }

      it "renders the show template" do
        get :show, params: { id: game.id }
        expect(response).to render_template(:show)
      end

      it "assigns @game" do
        get :show, params: { id: game.id }
        expect(assigns(:game)).to eq(game)
      end
    end

    context "when the current user is not an admin" do
      let(:current_user) { create(:user) }

      it "redirects to the root path" do
        get :show, params: { id: game.id }
        expect(response).to redirect_to(root_path)
      end
    end

    context "when the current user is not signed in" do
      let(:current_user) { nil }

      it "redirects to the sign in page" do
        get :show, params: { id: game.id }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "GET #new" do
    context "when the current user is an admin" do
      let(:current_user) { create(:user, admin: true) }

      it "renders the new template" do
        get :new
        expect(response).to render_template(:new)
      end

      it "assigns @game" do
        get :new
        expect(assigns(:game)).to be_a_new(Game)
      end
    end

    context "when the current user is not an admin" do
      let(:current_user) { create(:user) }

      it "redirects to the root path" do
        get :new
        expect(response).to redirect_to(root_path)
      end
    end

    context "when the current user is not signed in" do
      let(:current_user) { nil }

      it "redirects to the sign in page" do
        get :new
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "POST #create" do
    let(:letters) { Game::LETTERS.keys.sample(25).join }
    let(:valid_params) { { game: { letters: letters, min_words: 1, max_words: 100 } } }
    let(:invalid_params) { { game: { letters: "", min_words: 0, max_words: 0 } } }

    context "when the current user is an admin" do
      let(:current_user) { create(:user, admin: true) }

      context "with valid params" do
        it "creates a new game" do
          expect {
            post :create, params: valid_params
          }.to change(Game, :count).by(1)

          game = Game.last
          expect(game.letters).to eq(letters)
          expect(game.min_words).to eq(1)
          expect(game.max_words).to eq(100)
        end

        it "redirects to the created game" do
          post :create, params: valid_params
          expect(response).to redirect_to(admin_game_path(Game.last))
        end
      end

      context "with invalid params" do
        it "does not create a new game" do
          expect {
            post :create, params: invalid_params
          }.not_to change(Game, :count)
        end

        it "renders the new template" do
          post :create, params: invalid_params
          expect(response).to render_template(:new)
        end
      end
    end

    context "when the current user is not an admin" do
      let(:current_user) { create(:user) }

      it "redirects to the root path" do
        post :create, params: valid_params
        expect(response).to redirect_to(root_path)
      end
    end

    context "when the current user is not signed in" do
      let(:current_user) { nil }

      it "redirects to the sign in page" do
        post :create, params: valid_params
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:game) { create(:game) }

    before { allow(Game).to receive(:find).with(game.id.to_s).and_return(game) }

    context "when the current user is an admin" do
      let(:current_user) { create(:user, admin: true) }

      it "calls destroy on the game" do
        expect(game).to receive(:destroy)
        delete :destroy, params: { id: game.id }
      end

      it "redirects to the game index page with a notice when the game can be destroyed" do
        allow(game).to receive(:destroy).and_return(true)
        delete :destroy, params: { id: game.id }
        expect(response).to redirect_to(admin_games_path)
        expect(flash[:notice]).to eq(I18n.t("admin.games.destroy.success_notice"))
      end

      it "redirects to the game show page with an alert when the game cannot be destroyed" do
        allow(game).to receive(:destroy).and_return(false)
        delete :destroy, params: { id: game.id }
        expect(response).to redirect_to(admin_game_path(game))
        expect(flash[:alert]).to eq(I18n.t("admin.games.destroy.failure_notice"))
      end
    end

    context "when the current user is not an admin" do
      let(:current_user) { create(:user) }

      it "redirects to the root path" do
        delete :destroy, params: { id: game.id }
        expect(response).to redirect_to(root_path)
      end

      it "does not call destroy on the game" do
        expect(game).not_to receive(:destroy)
        delete :destroy, params: { id: game.id }
      end
    end

    context "when the current user is not signed in" do
      let(:current_user) { nil }

      it "redirects to the sign in page" do
        delete :destroy, params: { id: game.id }
        expect(response).to redirect_to(new_session_path)
      end

      it "does not call destroy on the game" do
        expect(game).not_to receive(:destroy)
        delete :destroy, params: { id: game.id }
      end
    end
  end
end
