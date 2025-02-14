require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  describe "GET #edit" do
    let(:user) { create(:user) }

    context "when the user is authenticated" do
      before { sign_in_as(user) }

      it "renders the edit template" do
        get :edit
        expect(response).to render_template(:edit)
      end
    end

    context "when the user is not authenticated" do
      it "redirects to the sign in page" do
        get :edit
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "PUT #update" do
    let(:original_password) { "old_password" }
    let(:user) { create(:user, password: original_password, password_confirmation: original_password) }
    let(:user_params) { { username: "test", name: "Test User", email_address: "test@example.com", password: "new_password", password_confirmation: "new_password" } }

    context "when the user is authenticated" do
      before { sign_in_as(user) }

      context "with valid parameters" do
        it "updates the user" do
          put :update, params: { user: user_params }
          expect(response).to redirect_to(root_path)
          expect(flash[:notice]).to eq(I18n.t("accounts.update.success_notice"))

          user = User.authenticate_by(email_address: "test@example.com", password: "new_password")

          expect(user.username).to eq("test")
          expect(user.name).to eq("Test User")
        end
      end

      context "with valid parameters but without password" do
        it "updates the user except for the password" do
          put :update, params: { user: user_params.merge(password: "", password_confirmation: "") }
          expect(response).to redirect_to(root_path)
          expect(flash[:notice]).to eq(I18n.t("accounts.update.success_notice"))

          user = User.authenticate_by(email_address: "test@example.com", password: "old_password")

          expect(user.username).to eq("test")
          expect(user.name).to eq("Test User")
          expect(user.email_address).to eq("test@example.com")
        end
      end

      context "with invalid parameters" do
        it "renders the edit template with unprocessable entity status" do
          put :update, params: { user: user_params.merge(username: "") }
          expect(response).to render_template(:edit)
          expect(response.status).to eq(422)
        end
      end
    end

    context "when the user is not authenticated" do
      it "redirects to the sign in page" do
        put :update, params: { user: user_params }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
