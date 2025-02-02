require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe "GET #new" do
    it "returns a successful response" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    let(:user) { create(:user, password: "password123", password_confirmation: "password123") }
    let(:valid_params) { { email_address: user.email_address, password: "password123" } }
    let(:invalid_params) { { email_address: user.email_address, password: "wrong_password" } }

    context "with valid credentials" do
      context "when the after_authentication_url is set" do
        it "signs in the user and redirects to the after_authentication_url" do
          session[:return_to_after_authenticating] = "/path"
          post :create, params: valid_params
          expect(response).to redirect_to("/path")
          expect(flash[:notice]).to eq(I18n.t("sessions.create.success_notice"))
        end
      end

      context "when the after_authentication_url is not set" do
        it "signs in the user and redirects to the root path" do
          post :create, params: valid_params
          expect(response).to redirect_to(root_path)
          expect(flash[:notice]).to eq(I18n.t("sessions.create.success_notice"))
        end
      end
    end

    context "with valid legacy credentials" do
      let(:user) { create(:user, :with_legacy_password_1) }
      let(:valid_params) { { email_address: user.email_address, password: "qwerty42" } }

      context "when the after_authentication_url is set" do
        it "signs in the user and redirects to the after_authentication_url" do
          session[:return_to_after_authenticating] = "/path"
          post :create, params: valid_params
          expect(response).to redirect_to("/path")
          expect(flash[:notice]).to eq(I18n.t("sessions.create.success_notice"))
        end
      end

      context "when the after_authentication_url is not set" do
        it "signs in the user and redirects to the root path" do
          post :create, params: valid_params
          expect(response).to redirect_to(root_path)
          expect(flash[:notice]).to eq(I18n.t("sessions.create.success_notice"))
        end
      end
    end

    context "with invalid credentials" do
      it "redirects back to sign in with an error" do
        post :create, params: invalid_params
        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to eq(I18n.t("sessions.create.error_alert"))
      end
    end

    context "when rate limited" do
      before do
        11.times { post :create, params: invalid_params }
      end

      it "redirects with rate limit message" do
        expect(response).to redirect_to(new_session_url)
        expect(flash[:alert]).to eq("Try again later.")
      end
    end
  end

  describe "DELETE #destroy" do
    let(:user) { create(:user) }

    before do
      sign_in_as(user)
    end

    it "signs out the user" do
      delete :destroy
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq(I18n.t("sessions.destroy.success_notice"))
    end

    it "clears the session cookie" do
      delete :destroy
      expect(cookies[:session_id]).to be_nil
    end

    it "triggers a clearing of site data in the browser using the Clear-Site-Data header" do
      delete :destroy
      expect(response.headers["Clear-Site-Data"]).to eq('"cache","storage"')
    end
  end
end
