require 'rails_helper'

RSpec.describe RecipeManagement::StatsService do
  let(:service) { described_class.new }

  # -------------------------------------------------------
  describe '#call' do
    let(:user) { create(:user) }
    let(:author) { create(:author) }
    let(:category) { create(:category, name: 'Dessert') }

    let!(:recipe_1) do
      create(:recipe, author: author, created_at: Time.zone.parse('2025-05-10')).tap do |r|
        r.categories << category
      end
    end

    let!(:recipe_2) do
      create(:recipe, author: author, created_at: Time.zone.parse('2025-04-15')).tap do |r|
        r.categories << category
      end
    end

    let(:recipes) { Recipe.where(id: [recipe_1.id, recipe_2.id]) }

    before do
      create(:like, recipe: recipe_1, user: user)
      create(:like, recipe: recipe_2, user: user)
    end

    # -------------------------------------------------------
    context 'when timeframe is "month"' do
      it 'returns stats grouped by category and month' do
        aggregate_failures do
          result = service.call(recipes: recipes, timeframe: 'month')

          expect(result[:error]).to be_nil
          expect(result[:stats].size).to eq(2)

          stat_1 = result[:stats].first
          expect(stat_1[:category]).to eq('Dessert')
          expect(stat_1[:timeframe]).to eq('month')
          expect(stat_1[:year]).to eq(2025)
          expect(stat_1[:month]).to eq(5)
          expect(stat_1[:week]).to be_nil
          expect(stat_1[:recipe_count]).to eq(1)
          expect(stat_1[:total_likes]).to eq(1)

          stat_2 = result[:stats].last
          expect(stat_2[:category]).to eq('Dessert')
          expect(stat_2[:timeframe]).to eq('month')
          expect(stat_2[:year]).to eq(2025)
          expect(stat_2[:month]).to eq(4)
          expect(stat_2[:week]).to be_nil
          expect(stat_2[:recipe_count]).to eq(1)
          expect(stat_2[:total_likes]).to eq(1)
        end
      end
    end

    # -------------------------------------------------------
    context 'when timeframe is "week"' do
      it 'returns stats grouped by category and week' do
        aggregate_failures do
          result = service.call(recipes: recipes, timeframe: 'week')

          expect(result[:error]).to be_nil

          stat_1 = result[:stats].first
          expect(stat_1[:category]).to eq('Dessert')
          expect(stat_1[:timeframe]).to eq('week')
          expect(stat_1[:year]).to eq(2025)
          expect(stat_1[:month]).to be_nil
          expect(stat_1[:week]).to eq(18)
          expect(stat_1[:recipe_count]).to eq(1)
          expect(stat_1[:total_likes]).to eq(1)

          stat_2 = result[:stats].last
          expect(stat_2[:category]).to eq('Dessert')
          expect(stat_2[:timeframe]).to eq('week')
          expect(stat_2[:year]).to eq(2025)
          expect(stat_2[:month]).to be_nil
          expect(stat_2[:week]).to eq(15)
          expect(stat_2[:recipe_count]).to eq(1)
          expect(stat_2[:total_likes]).to eq(1)
        end
      end
    end

    # -------------------------------------------------------
    context 'when timeframe is invalid' do
      it 'returns an error' do
        result = service.call(recipes: recipes, timeframe: 'year')

        expect(result[:error]).to eq('Invalid time frame. Expected: `week`, or `month`')
        expect(result[:stats]).to be_nil
      end
    end
  end
end
