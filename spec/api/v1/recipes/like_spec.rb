require 'rails_helper'

RSpec.describe "recipes#like", type: :request do
  let(:user) { create(:user) }
  let!(:recipe) { create(:recipe) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  subject(:make_request) do
    post "/api/v1/recipes/#{recipe_id}/like"
  end

  let(:recipe_id) { recipe.id }

  # -------------------------------------------------------
  describe 'liking a recipe' do
    it 'creates a like and returns 201' do
      expect {
        make_request
      }.to change { user.likes.count }.by(1)

      expect(response.status).to eq(201), response.body
      expect(response.parsed_body["message"]).to eq("Recipe liked successfully")
    end

    # -------------------------------------------------------
    context 'when already liked' do
      before do
        create(:like, user: user, recipe: recipe)
      end

      it 'returns 422 and does not create a new like' do
        expect {
          make_request
        }.not_to change { user.likes.count }

        expect(response.status).to eq(422), response.body
        expect(response.parsed_body["errors"]).to include("Recipe already liked")
      end
    end
    
    # -------------------------------------------------------
    context 'when the recipe does not exist' do
      let(:recipe_id) { -1 }

      it 'returns 404' do
        make_request
        expect(response.status).to eq(404)
        expect(response.parsed_body["errors"]).to include("Recipe not found")
      end
    end
  end
end