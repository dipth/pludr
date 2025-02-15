require 'rails_helper'

RSpec.describe Admin::DashboardsController, type: :controller do
  describe "GET #index" do
    before do
      sign_in_as(user) if user
    end

    context "when the user is an admin" do
      let(:user) { create(:user, admin: true) }

      it "renders the index template" do
        get :index
        expect(response).to render_template(:index)
      end
    end

    context "when the user is not an admin" do
      let(:user) { create(:user) }

      it "redirects to the root path" do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end

    context "when the user is not signed in" do
      let(:user) { nil }

      it "redirects to the sign in page" do
        get :index
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
