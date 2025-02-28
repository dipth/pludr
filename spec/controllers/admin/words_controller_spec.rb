require 'rails_helper'

RSpec.describe Admin::WordsController, type: :controller do
  before { sign_in_as(current_user) if current_user }

  describe "GET #index" do
    context "when the current user is an admin" do
      let(:current_user) { create(:user, admin: true) }

      it "renders the index template" do
        get :index
        expect(response).to render_template(:index)
      end

      it "assigns @words" do
        get :index
        expect(assigns(:words)).to be_a(ActiveRecord::Relation)
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
        allow(Word).to receive(:ransack).and_return(double(result: Word.all))
        get :index, params: { q: { value_cont: "test" } }
        expect(Word).to have_received(:ransack).with(value_cont: "test")
      end

      it "sorts words by value by default" do
        allow(Word).to receive(:ransack).and_return(double(result: Word.all))
        get :index
        expect(Word).to have_received(:ransack).with(s: "value asc")
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
    let(:word) { create(:word) }

    context "when the current user is an admin" do
      let(:current_user) { create(:user, admin: true) }

      it "renders the show template" do
        get :show, params: { id: word.id }
        expect(response).to render_template(:show)
      end

      it "assigns @word" do
        get :show, params: { id: word.id }
        expect(assigns(:word)).to eq(word)
      end
    end

    context "when the current user is not an admin" do
      let(:current_user) { create(:user) }

      it "redirects to the root path" do
        get :show, params: { id: word.id }
        expect(response).to redirect_to(root_path)
      end
    end

    context "when the current user is not signed in" do
      let(:current_user) { nil }

      it "redirects to the sign in page" do
        get :show, params: { id: word.id }
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

      it "assigns @word" do
        get :new
        expect(assigns(:word)).to be_a_new(Word)
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
    let(:valid_params) { { word: { value: "test" } } }
    let(:invalid_params) { { word: { value: "" } } }

    context "when the current user is an admin" do
      let(:current_user) { create(:user, admin: true) }

      context "with valid params" do
        it "creates a new word" do
          expect {
            post :create, params: valid_params
          }.to change(Word, :count).by(1)
        end

        it "redirects to the created word" do
          post :create, params: valid_params
          expect(response).to redirect_to(admin_word_path(Word.last))
        end
      end

      context "with invalid params" do
        it "does not create a new word" do
          expect {
            post :create, params: invalid_params
          }.not_to change(Word, :count)
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

  describe "GET #edit" do
    let(:word) { create(:word) }

    context "when the current user is an admin" do
      let(:current_user) { create(:user, admin: true) }

      it "renders the edit template" do
        get :edit, params: { id: word.id }
        expect(response).to render_template(:edit)
      end

      it "assigns @word" do
        get :edit, params: { id: word.id }
        expect(assigns(:word)).to eq(word)
      end

      it "redirects to the word show page if the word is deleted" do
        word.delete!
        get :edit, params: { id: word.id }
        expect(response).to redirect_to(admin_word_path(word))
        expect(flash[:alert]).to eq(I18n.t("admin.words.deleted_words_are_protected"))
      end
    end

    context "when the current user is not an admin" do
      let(:current_user) { create(:user) }

      it "redirects to the root path" do
        get :edit, params: { id: word.id }
        expect(response).to redirect_to(root_path)
      end
    end

    context "when the current user is not signed in" do
      let(:current_user) { nil }

      it "redirects to the sign in page" do
        get :edit, params: { id: word.id }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "PATCH #update" do
    let(:word) { create(:word, value: "original") }
    let(:valid_params) { { id: word.id, word: { value: "updated" } } }
    let(:invalid_params) { { id: word.id, word: { value: "" } } }

    context "when the current user is an admin" do
      let(:current_user) { create(:user, admin: true) }

      context "with valid params" do
        it "updates the word" do
          patch :update, params: valid_params
          word.reload
          expect(word.value).to eq("UPDATED")
        end

        it "redirects to the word" do
          patch :update, params: valid_params
          expect(response).to redirect_to(admin_word_path(word))
        end

        it "redirects to the word show page without updating the word if the word is deleted" do
          word.delete!
          patch :update, params: valid_params
          expect(response).to redirect_to(admin_word_path(word))
          expect(flash[:alert]).to eq(I18n.t("admin.words.deleted_words_are_protected"))
          expect(word.value).to eq("ORIGINAL")
        end
      end

      context "with invalid params" do
        it "does not update the word" do
          patch :update, params: invalid_params
          word.reload
          expect(word.value).to eq("ORIGINAL")
        end

        it "renders the edit template" do
          patch :update, params: invalid_params
          expect(response).to render_template(:edit)
        end
      end
    end

    context "when the current user is not an admin" do
      let(:current_user) { create(:user) }

      it "redirects to the root path" do
        patch :update, params: valid_params
        expect(response).to redirect_to(root_path)
      end
    end

    context "when the current user is not signed in" do
      let(:current_user) { nil }

      it "redirects to the sign in page" do
        patch :update, params: valid_params
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:word) { create(:word) }

    before { allow(Word).to receive(:find).with(word.id.to_s).and_return(word) }

    context "when the current user is an admin" do
      let(:current_user) { create(:user, admin: true) }

      it "calls delete! on the word" do
        expect(word).to receive(:delete!)
        delete :destroy, params: { id: word.id }
      end

      it "redirects to the word show page" do
        delete :destroy, params: { id: word.id }
        expect(response).to redirect_to(admin_word_path(word))
      end
    end

    context "when the current user is not an admin" do
      let(:current_user) { create(:user) }

      it "redirects to the root path" do
        delete :destroy, params: { id: word.id }
        expect(response).to redirect_to(root_path)
      end

      it "does not call delete! on the word" do
        expect(word).not_to receive(:delete!)
        delete :destroy, params: { id: word.id }
      end
    end

    context "when the current user is not signed in" do
      let(:current_user) { nil }

      it "redirects to the sign in page" do
        delete :destroy, params: { id: word.id }
        expect(response).to redirect_to(new_session_path)
      end

      it "does not call delete! on the word" do
        expect(word).not_to receive(:delete!)
        delete :destroy, params: { id: word.id }
      end
    end
  end

  describe "PATCH #restore" do
    let!(:word) { create(:word, deleted_at: Time.current) }

    before { allow(Word).to receive(:find).with(word.id.to_s).and_return(word) }

    context "when the current user is an admin" do
      let(:current_user) { create(:user, admin: true) }

      it "calls restore! on the word" do
        expect(word).to receive(:restore!)
        patch :restore, params: { id: word.id }
      end

      it "redirects to the word show page" do
        patch :restore, params: { id: word.id }
        expect(response).to redirect_to(admin_word_path(word))
      end
    end

    context "when the current user is not an admin" do
      let(:current_user) { create(:user) }

      it "redirects to the root path" do
        patch :restore, params: { id: word.id }
        expect(response).to redirect_to(root_path)
      end

      it "does not call restore! on the word" do
        expect(word).not_to receive(:restore!)
        patch :restore, params: { id: word.id }
      end
    end

    context "when the current user is not signed in" do
      let(:current_user) { nil }

      it "redirects to the sign in page" do
        patch :restore, params: { id: word.id }
        expect(response).to redirect_to(new_session_path)
      end

      it "does not call restore! on the word" do
        expect(word).not_to receive(:restore!)
        patch :restore, params: { id: word.id }
      end
    end
  end
end
