require 'rails_helper'

RSpec.describe "recipes#unlike", type: :request do
  let(:user) { create(:user) }
  let!(:recipe) { create(:recipe) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  subject(:make_request) do
    delete "/api/v1/recipes/#{recipe_id}/unlike"
  end

  let(:recipe_id) { recipe.id }

  # -------------------------------------------------------
  describe 'unliking a recipe' do
    #-------------------------------------------------------
    context 'when the recipe is liked' do
      before do
        create(:like, user: user, recipe: recipe)
      end

      it 'removes the like and returns 200' do
        expect {
          make_request
        }.to change { user.likes.count }.by(-1)

        expect(response.status).to eq(200), response.body
        expect(response.parsed_body["message"]).to eq("Recipe unliked successfully")
      end
    end

    #-------------------------------------------------------
    context 'when the like does not exist' do
      it 'returns 404 with proper error message' do
        make_request

        expect(response.status).to eq(404), response.body
        expect(response.parsed_body["errors"]).to include("Recipe not found")
      end
    end

    #-------------------------------------------------------
    context 'when recipe is liked but like record is missing' do
      before do
        create(:like, user: user, recipe: recipe).destroy
        allow(user).to receive_message_chain(:liked_recipes, :find_by).and_return(recipe)
        allow(user).to receive_message_chain(:likes, :find_by).and_return(nil)
      end

      it 'returns 404 with specific message' do
        make_request

        expect(response.status).to eq(404), response.body
        expect(response.parsed_body["errors"]).to include("Recipie wasn't liked")
      end
    end
  end
end