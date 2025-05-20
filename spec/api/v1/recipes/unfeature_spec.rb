require 'rails_helper'

RSpec.describe 'recipes#unfeature', type: :request do
  let(:current_user) { create(:user) }
  let(:author) { create(:author, user: current_user) }
  let(:recipe) { create(:recipe, author: author, featured: true) }
  let(:recipe_id) { recipe.id }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)
  end

  subject(:make_request) do
    delete "/api/v1/recipes/#{recipe_id}/unfeature"
  end

  # -------------------------------------------------------
  describe 'unfeaturing a recipe' do
    it 'unfeatures a recipe successfully' do
      expect do
        make_request
      end.to change { recipe.reload.featured }.from(true).to(false)

      expect(response.status).to eq(200)
      expect(response.parsed_body['message']).to eq('Recipe unfeatured successfully')
    end

    # -------------------------------------------------------
    context 'when the recipe is not featured' do
      before do
        recipe.update!(featured: false)
      end

      it 'returns 422' do
        make_request

        expect(response.status).to eq(422)
        expect(response.parsed_body['errors']).to include('Recipe is not featured')
      end
    end

    # -------------------------------------------------------
    context 'when the user is not the author' do
      let(:other_recipe) { create(:recipe, featured: true) }
      let(:recipe_id) { other_recipe.id }

      it 'returns 403' do
        make_request

        expect(response.status).to eq(403)
        expect(response.parsed_body['errors']).to include('You are not the author of this recipe')
      end
    end

    # -------------------------------------------------------
    context 'when the recipe does not exist' do
      let(:recipe_id) { -1 }

      it 'returns 404' do
        make_request

        expect(response.status).to eq(404)
        expect(response.parsed_body['errors']).to include('Recipe not found')
      end
    end
  end
end
