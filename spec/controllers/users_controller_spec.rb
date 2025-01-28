require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe "GET #new" do
    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    let(:user_params) { { username: "test", name: "Test User", email_address: "test@example.com", password: "password", password_confirmation: "password" } }

    context "with valid parameters" do
      it "creates a new user" do
        post :create, params: { user: user_params }
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t("users.create.success_notice"))
        expect(User.find_by(email_address: "test@example.com")).to be_present
      end
    end

    context "with invalid parameters" do
      it "renders the new template with unprocessable entity status" do
        post :create, params: { user: user_params.merge(username: "") }
        expect(response).to render_template(:new)
        expect(response.status).to eq(422)
        expect(User.find_by(email_address: "test@example.com")).to be_nil
      end
    end
  end
end
