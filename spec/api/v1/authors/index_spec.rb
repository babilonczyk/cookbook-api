require 'rails_helper'

RSpec.describe "authors#index", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/api/v1/authors", params: params
  end

  # -------------------------------------------------------
  describe 'basic fetch' do
    let!(:author1) { create(:author) }
    let!(:author2) { create(:author) }

    it 'works' do
      expect(AuthorResource).to receive(:all).and_call_original
      make_request
      expect(response.status).to eq(200), response.body
      expect(d.map(&:jsonapi_type).uniq).to match_array(['authors'])
      expect(d.map(&:id)).to match_array([author1.id, author2.id])
    end
  end
end
