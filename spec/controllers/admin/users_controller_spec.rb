require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  describe "GET #index" do
    before do
      sign_in_as(user) if user
    end

    context "when the current user is an admin" do
      let(:user) { create(:user, admin: true) }

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
      let(:user) { create(:user) }

      it "redirects to the root path" do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end

    context "when the current user is not signed in" do
      let(:user) { nil }

      it "redirects to the sign in page" do
        get :index
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
