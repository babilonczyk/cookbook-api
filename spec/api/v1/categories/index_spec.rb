require 'rails_helper'

RSpec.describe "categories#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/api/v1/categories", params: params
  end

  # -------------------------------------------------------
  describe 'basic fetch' do
    let!(:category1) { create(:category) }
    let!(:category2) { create(:category) }

    it 'works' do
      expect(CategoryResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['categories'])
      expect(d.map(&:id)).to match_array([category1.id, category2.id])
    end
  end
end
