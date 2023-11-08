require 'rails_helper'

RSpec.describe "Links" do
  describe "CREATE" do
    let(:create_link) { Link.create(url: url) }
    let(:url) { 'http://www.testing.com/' }

    it 'should create a Link' do
      expect { create_link }.to change { Link.count }.by(1)
    end
  end
end
