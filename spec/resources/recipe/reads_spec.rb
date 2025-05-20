require 'rails_helper'

RSpec.describe RecipeResource, type: :resource do
  describe 'serialization' do
    let!(:recipe) { create(:recipe) }
    let!(:user_1) { create(:user) }
    let!(:user_2) { create(:user) }

    before do
      create(:like, recipe: recipe, user: user_1)
      create(:like, recipe: recipe, user: user_2)
    end

    it 'works' do
      render
      data = jsonapi_data[0]
      expect(data.id).to eq(recipe.id)
      expect(data.jsonapi_type).to eq('recipes')
    end

    it 'includes likes count' do
      render
      data = jsonapi_data[0]
      expect(data.attributes[:likes_count]).to eq(2)
    end
  end

  describe 'filtering' do
    let!(:recipe1) { create(:recipe) }
    let!(:recipe2) { create(:recipe) }

    context 'by id' do
      before do
        params[:filter] = { id: { eq: recipe2.id } }
      end

      it 'works' do
        render
        expect(d.map(&:id)).to eq([recipe2.id])
      end
    end

    context 'by liked_by_user_ids' do
      let!(:user) { create(:user) }
      let!(:liked_recipe) { create(:recipe) }
      let!(:unliked_recipe) { create(:recipe) }
    
      before do
        create(:like, user: user, recipe: liked_recipe)
        params[:filter] = { liked_by_user_ids: { eq: user.id } }
      end
    
      it 'returns only recipes liked by the user' do
        render
        expect(d.map(&:id)).to eq([liked_recipe.id])
      end
    end
  end

  describe 'sorting' do
    describe 'by id' do
      let!(:recipe1) { create(:recipe) }
      let!(:recipe2) { create(:recipe) }

      context 'when ascending' do
        before do
          params[:sort] = 'id'
        end

        it 'works' do
          render
          expect(d.map(&:id)).to eq([
            recipe1.id,
            recipe2.id
          ])
        end
      end

      context 'when descending' do
        before do
          params[:sort] = '-id'
        end

        it 'works' do
          render
          expect(d.map(&:id)).to eq([
            recipe2.id,
            recipe1.id
          ])
        end
      end
    end
  end

  describe 'sideloading' do
    # ... your tests ...
  end
end
