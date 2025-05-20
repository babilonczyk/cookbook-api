require 'rails_helper'

RSpec.describe 'recipes#feature', type: :request do
  let(:current_user) { create(:user) }
  let(:author) { create(:author, user: current_user) }
  let(:recipe) { create(:recipe, author: author) }
  let(:recipe_id) { recipe.id }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)
  end

  subject(:make_request) do
    post "/api/v1/recipes/#{recipe_id}/feature"
  end

  # -------------------------------------------------------
  describe 'featuring a recipe' do
    it 'features a top 10 recipe successfully' do
      make_request

      expect(response.status).to eq(201)
      expect(response.parsed_body['message']).to eq('Recipe featured successfully')
      expect(recipe.reload.featured).to be true
    end

    # -------------------------------------------------------
    context 'when recipe is not in top 10' do
      let!(:low_ranked_recipe) { create(:recipe, author: author) }
      let(:recipe_id) { low_ranked_recipe.id }

      before do
        users = create_list(:user, 10)
        users.each do |user|
          new_recipe = create(:recipe, author: author)
          create(:like, recipe: new_recipe, user: user)
        end
      end

      it 'returns 403' do
        make_request
        expect(response.status).to eq(403)
        expect(response.parsed_body['errors']).to include('Recipe is not in the top 10')
      end
    end

    # -------------------------------------------------------
    context 'when recipe is already featured' do
      before do
        recipe.update!(featured: true)
      end

      it 'returns 422' do
        make_request
        expect(response.status).to eq(422)
        expect(response.parsed_body['errors']).to include('Recipe already featured')
      end
    end

    # -------------------------------------------------------
    context 'when user is not the author' do
      let(:other_recipe) { create(:recipe) }
      let(:recipe_id) { other_recipe.id }

      it 'returns 403' do
        make_request
        expect(response.status).to eq(403)
        expect(response.parsed_body['errors']).to include('You are not the author of this recipe')
      end
    end

    # -------------------------------------------------------
    context 'when recipe does not exist' do
      let(:recipe_id) { -1 }

      it 'returns 404' do
        make_request
        expect(response.status).to eq(404)
        expect(response.parsed_body['errors']).to include('Recipe not found')
      end
    end
  end
end
