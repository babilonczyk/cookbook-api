require 'rails_helper'

RSpec.describe "authors#show", type: :request do
  let(:params) { {} }

  subject(:make_request) do
    jsonapi_get "/api/v1/authors/#{author.id}", params: params
  end

  # -------------------------------------------------------
  describe 'basic fetch' do
    let!(:author) { create(:author) }

    it 'works' do
      expect(AuthorResource).to receive(:find).and_call_original
      make_request
      expect(response.status).to eq(200)
      expect(d.jsonapi_type).to eq('authors')
      expect(d.id).to eq(author.id)
    end
  end
end
