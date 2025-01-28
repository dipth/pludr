require 'rails_helper'

RSpec.describe PasswordsController, type: :controller do
  describe "GET #new" do
    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "when user exists" do
      let(:user) { create(:user) }

      it "sends reset password email" do
        expect {
          post :create, params: { email_address: user.email_address }
        }.to have_enqueued_mail(PasswordsMailer, :reset)
      end

      it "redirects to login with success message" do
        post :create, params: { email_address: user.email_address }
        expect(response).to redirect_to(new_session_path)
        expect(flash[:notice]).to eq(I18n.t("passwords.create.success_notice"))
      end
    end

    context "when user does not exist" do
      it "redirects to login with same message for security" do
        post :create, params: { email_address: "nonexistent@example.com" }
        expect(response).to redirect_to(new_session_path)
        expect(flash[:notice]).to eq(I18n.t("passwords.create.success_notice"))
      end

      it "does not send any email" do
        expect {
          post :create, params: { email_address: "nonexistent@example.com" }
        }.not_to have_enqueued_mail(PasswordsMailer)
      end
    end
  end

  describe "GET #edit" do
    context "with valid token" do
      let(:user) { create(:user) }
      let(:token) { user.password_reset_token }

      it "renders the edit template" do
        get :edit, params: { token: token }
        expect(response).to render_template(:edit)
      end
    end

    context "with invalid token" do
      it "redirects to new password path" do
        get :edit, params: { token: "invalid_token" }
        expect(response).to redirect_to(new_password_path)
        expect(flash[:alert]).to eq(I18n.t("passwords.shared.invalid_token_alert"))
      end
    end
  end

  describe "PATCH #update" do
    context "with valid token" do
      let(:user) { create(:user) }
      let(:token) { user.password_reset_token }

      context "with matching passwords" do
        let(:new_password) { "new_password123" }

        it "updates the password" do
          patch :update, params: {
            token: token,
            password: new_password,
            password_confirmation: new_password
          }

          expect(user.reload.authenticate(new_password)).to be_truthy
          expect(response).to redirect_to(new_session_path)
          expect(flash[:notice]).to eq(I18n.t("passwords.update.success_notice"))
        end

        it "does not allow updating other attributes of the user" do
          patch :update, params: {
            token: token,
            password: new_password,
            password_confirmation: new_password,
            name: "New Name"
          }

          expect(user.reload.name).not_to eq("New Name")
        end
      end

      context "with non-matching passwords" do
        it "redirects back to edit with error" do
          patch :update, params: {
            token: token,
            password: "password123",
            password_confirmation: "different123"
          }

          expect(response).to redirect_to(edit_password_path(token))
          expect(flash[:alert]).to eq(I18n.t("passwords.update.error_alert"))
        end
      end
    end

    context "with invalid token" do
      it "redirects to new password path" do
        patch :update, params: {
          token: "invalid_token",
          password: "password123",
          password_confirmation: "password123"
        }

        expect(response).to redirect_to(new_password_path)
        expect(flash[:alert]).to match(/Password reset link is invalid/)
      end
    end
  end
end
