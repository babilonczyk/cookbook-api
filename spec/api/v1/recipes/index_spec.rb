require 'rails_helper'

RSpec.describe "recipes#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/api/v1/recipes", params: params
  end

  # -------------------------------------------------------
  describe 'basic fetch' do
    let!(:recipe1) { create(:recipe) }
    let!(:recipe2) { create(:recipe) }

    it 'works' do
      expect(RecipeResource).to receive(:all).and_call_original
      
      make_request

      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['recipes'])
      expect(d.map(&:id)).to match_array([recipe1.id, recipe2.id])
    end
  end

  # -------------------------------------------------------
  describe 'filters' do
    let(:user) { create(:user) }
    let!(:liked_recipe) { create(:recipe) }
    let!(:unliked_recipe) { create(:recipe) }
  
    before do
      create(:like, user: user, recipe: liked_recipe)
    end
  
    let(:params) do
      { filter: { liked_by_user_ids: { eq: user.id } } }
    end

    it 'returns only recipes liked by the specified user' do
      make_request

      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['recipes'])
      expect(d.map(&:id).map(&:to_i)).to match_array([liked_recipe.id])
    end
  end
end
