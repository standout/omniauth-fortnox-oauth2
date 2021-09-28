# frozen_string_literal: true

require 'helper'

describe OmniAuth::FortnoxOAuth2::API do
  subject(:api) { OmniAuth::FortnoxOAuth2::API.new(token) }

  let(:token) { 'abc' }

  describe '#get' do
    let(:headers) do
      {
        'Accept' => 'application/json',
        'Authorization' => 'Bearer abc',
        'Content-Type' => 'application/json'
      }
    end

    before do
      stub_request(:get, 'https://api.fortnox.se/3/companyinformation')
        .with(
          headers: headers
        ).to_return(status: 200, body: { 'x' => 'o' }.to_json, headers: {})
    end

    it 'performs the OmniAuth::Strategy included hook' do
      api.get('/companyinformation')
      expect(a_request(:get, 'https://api.fortnox.se/3/companyinformation'))
        .to have_been_made
        .once
    end
  end
end
