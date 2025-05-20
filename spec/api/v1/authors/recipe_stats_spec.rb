require 'rails_helper'

RSpec.describe 'authors#recipe_stats', type: :request do
  let(:author) { create(:author) }
  let(:category) { create(:category, name: 'Dessert') }
  let(:user) { create(:user) }

  let!(:recipe_1) do
    create(:recipe, author: author, created_at: Time.zone.parse('2025-05-05')).tap do |r|
      r.categories << category
    end
  end

  let!(:recipe_2) do
    create(:recipe, author: author, created_at: Time.zone.parse('2025-04-10')).tap do |r|
      r.categories << category
    end
  end

  before do
    create(:like, recipe: recipe_1, user: user)
    create(:like, recipe: recipe_2, user: user)
  end

  subject(:make_request) do
    get "/api/v1/authors/#{author.id}/recipe_stats", params: params
  end

  # -------------------------------------------------------
  describe 'basic fetch' do
    let(:params) { { group_by: 'month' } }

    it 'returns correct recipe stats' do
      make_request

      expect(response.status).to eq(200), response.body
      expect(response.parsed_body['data']).to be_an(Array)

      stat_1 = response.parsed_body['data'].first
      expect(stat_1['category']).to eq('Dessert')
      expect(stat_1['timeframe']).to eq('month')
      expect(stat_1['year']).to eq(2025)
      expect(stat_1['month']).to eq(5)
      expect(stat_1['week']).to be_nil
      expect(stat_1['recipe_count']).to eq(1)
      expect(stat_1['total_likes']).to eq(1)

      stat_2 = response.parsed_body['data'].last
      expect(stat_2['category']).to eq('Dessert')
      expect(stat_2['timeframe']).to eq('month')
      expect(stat_2['year']).to eq(2025)
      expect(stat_2['month']).to eq(4)
      expect(stat_2['week']).to be_nil
      expect(stat_2['recipe_count']).to eq(1)
      expect(stat_2['total_likes']).to eq(1)
    end
  end

  # -------------------------------------------------------
  describe 'invalid timeframe' do
    let(:params) { { group_by: 'decade' } }

    it 'returns 422 with error message' do
      make_request

      expect(response.status).to eq(422), response.body
      expect(response.parsed_body['errors']).to include('Invalid time frame. Expected: `week`, or `month`')
    end
  end

  # -------------------------------------------------------
  describe 'missing author' do
    subject(:make_request) do
      get '/api/v1/authors/999999/recipe_stats', params: { group_by: 'month' }
    end

    it 'returns 404' do
      make_request

      expect(response.status).to eq(404), response.body
      expect(response.parsed_body['errors']).to include('Author not found')
    end
  end
end
