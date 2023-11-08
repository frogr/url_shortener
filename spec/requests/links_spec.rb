require 'rails_helper'

RSpec.describe "Links" do
  describe "CREATE" do
    let(:create_link) { Link.create(url: url) }
    let(:url) { 'http://www.testing.com/' }

    it 'should create a Link' do
      expect { create_link }.to change { Link.count }.by(1)
    end
  end

  describe "SHOW" do
    let(:link) { Link.create!(url: url) }
    let(:url) { 'http://www.google.com'}

    it 'should redirect to the URL address' do
      get link_path(link.id)
      expect(response).to redirect_to(link.url)
    end
  end

  describe "GET #id_search" do
    let(:link) { Link.create!(url: 'http://www.google.com', link_id: 'testing') }
    let(:valid_id) { link.link_id }
    let(:invalid_id) { 'babababa' }
    let(:valid_search) { get "/search/#{valid_id}" }
    let(:invalid_search) { get "/search/#{invalid_id}"}

    it "redirects to the URL when given a valid ID" do
      valid_search
      expect(response).to have_http_status(302)
    end

    it "returns a 404 when given an invalid ID" do
      invalid_search
      expect(response).to have_http_status(404)
    end
  end
end
