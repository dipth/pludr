require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  before { sign_in_as(current_user) if current_user }

  describe "GET #index" do
    context "when the current user is an admin" do
      let(:current_user) { create(:user, admin: true) }

      it "renders the index template" do
        get :index
        expect(response).to render_template(:index)
      end

      it "assigns @users" do
        get :index
        expect(assigns(:users)).to be_a(ActiveRecord::Relation)
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
        allow(User).to receive(:ransack).and_return(double(result: User.all))
        get :index, params: { q: { username_cont: "test" } }
        expect(User).to have_received(:ransack).with(username_cont: "test")
      end

      it "sorts users by username by default" do
        allow(User).to receive(:ransack).and_return(double(result: User.all))
        get :index
        expect(User).to have_received(:ransack).with(s: "username asc")
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
    let(:user) { create(:user) }

    context "when the current user is an admin" do
      let(:current_user) { create(:user, admin: true) }

      it "renders the show template" do
        get :show, params: { id: user.id }
        expect(response).to render_template(:show)
      end

      it "assigns @user" do
        get :show, params: { id: user.id }
        expect(assigns(:user)).to eq(user)
      end

      it "assigns @recent_sessions with the 5 most recent sessions of the user" do
        sessions = build_list(:session, 6, user: user) do |session, i|
          session.created_at = 14.days.ago + i.days
          session.save!
        end
        get :show, params: { id: user.id }
        expect(assigns(:recent_sessions)).to eq(sessions.reverse.take(5))
      end
    end

    context "when the current user is not an admin" do
      let(:current_user) { create(:user) }

      it "redirects to the root path" do
        get :show, params: { id: user.id }
        expect(response).to redirect_to(root_path)
      end
    end

    context "when the current user is not signed in" do
      let(:current_user) { nil }

      it "redirects to the sign in page" do
        get :show, params: { id: user.id }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "GET #edit" do
    let(:user) { create(:user) }

    context "when the current user is an admin" do
      let(:current_user) { create(:user, admin: true) }

      it "renders the edit template" do
        get :edit, params: { id: user.id }
        expect(response).to render_template(:edit)
      end

      it "assigns @user" do
        get :edit, params: { id: user.id }
        expect(assigns(:user)).to eq(user)
      end
    end

    context "when the current user is not an admin" do
      let(:current_user) { create(:user) }

      it "redirects to the root path" do
        get :edit, params: { id: user.id }
        expect(response).to redirect_to(root_path)
      end
    end

    context "when the current user is not signed in" do
      let(:current_user) { nil }

      it "redirects to the sign in page" do
        get :edit, params: { id: user.id }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "PUT #update" do
    let(:user) { create(:user, password: "password", password_confirmation: "password") }
    let(:user_params) { { username: "new_username" } }

    context "when the current user is an admin" do
      let(:current_user) { create(:user, admin: true) }

      it "updates the user" do
        put :update, params: { id: user.id, user: user_params }
        expect(user.reload.username).to eq("new_username")
      end

      it "does not update the user's password if a new password is not provided" do
        original_password_digest = user.password_digest
        put :update, params: { id: user.id, user: user_params }
        expect(user.reload.password_digest).to eq(original_password_digest)
      end

      it "redirects to the user show page" do
        put :update, params: { id: user.id, user: user_params }
        expect(response).to redirect_to(admin_user_path(user))
      end

      it "sets a success notice" do
        put :update, params: { id: user.id, user: user_params }
        expect(flash[:notice]).to eq(I18n.t("admin.users.update.success_notice"))
      end

      context "when the update fails" do
        it "renders the edit template" do
          put :update, params: { id: user.id, user: { username: "" } }
          expect(response).to render_template(:edit)
        end
      end

      it "does not allow updating the user's admin status" do
        put :update, params: { id: user.id, user: { admin: true } }
        expect(user.reload.admin).to be_falsey
      end
    end

    context "when the current user is not an admin" do
      let(:current_user) { create(:user) }

      it "redirects to the root path" do
        put :update, params: { id: user.id, user: user_params }
        expect(response).to redirect_to(root_path)
      end

      it "does not update the user" do
        original_username = user.username
        put :update, params: { id: user.id, user: user_params }
        expect(user.reload.username).to eq(original_username)
      end
    end

    context "when the current user is not signed in" do
      let(:current_user) { nil }

      it "redirects to the sign in page" do
        put :update, params: { id: user.id, user: user_params }
        expect(response).to redirect_to(new_session_path)
      end

      it "does not update the user" do
        original_username = user.username
        put :update, params: { id: user.id, user: user_params }
        expect(user.reload.username).to eq(original_username)
      end
    end
  end

  describe "DELETE #destroy" do
    let(:user) { create(:user) }

    context "when the current user is an admin" do
      let(:current_user) { create(:user, admin: true) }

      it "redirects to the user index page" do
        delete :destroy, params: { id: user.id }
        expect(response).to redirect_to(admin_users_path)
      end

      it "deletes the user" do
        delete :destroy, params: { id: user.id }
        expect(User.exists?(id: user.id)).to be_falsey
      end

      it "sets a success notice" do
        delete :destroy, params: { id: user.id }
        expect(flash[:notice]).to eq(I18n.t("admin.users.destroy.success_notice"))
      end

      context "when the user is the current user" do
        let(:user) { current_user }

        it "redirects to the user show page" do
          delete :destroy, params: { id: user.id }
          expect(response).to redirect_to(admin_user_path(user))
        end

        it "does not delete the user" do
          delete :destroy, params: { id: user.id }
          expect(User.exists?(id: user.id)).to be_truthy
        end

        it "sets a cannot delete self alert" do
          delete :destroy, params: { id: user.id }
          expect(flash[:alert]).to eq(I18n.t("admin.users.destroy.cannot_delete_self"))
        end
      end
    end

    context "when the current user is not an admin" do
      let(:current_user) { create(:user) }

      it "redirects to the root path" do
        delete :destroy, params: { id: user.id }
        expect(response).to redirect_to(root_path)
      end

      it "does not delete the user" do
        delete :destroy, params: { id: user.id }
        expect(User.exists?(id: user.id)).to be_truthy
      end
    end

    context "when the current user is not signed in" do
      let(:current_user) { nil }

      it "redirects to the sign in page" do
        delete :destroy, params: { id: user.id }
        expect(response).to redirect_to(new_session_path)
      end

      it "does not delete the user" do
        delete :destroy, params: { id: user.id }
        expect(User.exists?(id: user.id)).to be_truthy
      end
    end
  end
end
