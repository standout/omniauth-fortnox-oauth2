# frozen_string_literal: true

require 'helper'

describe OmniAuth::Strategies::FortnoxOauth2 do
  def app
    lambda do |_env|
      [200, {}, ['Hello.']]
    end
  end

  subject(:fortnox_oauth2) do
    OmniAuth::Strategies::FortnoxOauth2.new(*args)
  end

  let(:args) { ['client_id', 'client_secret', options] }
  let(:options) { { callback_url: 'https://example.com/callback' } }

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
  end

  describe 'Subclassing Behavior' do
    it 'performs the OmniAuth::Strategy included hook' do
      expect(OmniAuth.strategies)
        .to include(OmniAuth::Strategies::FortnoxOauth2)
    end
  end

  describe '#client' do
    context 'client options' do
      let(:options) { { client_options: client_options } }
      let(:client_options) { {} }

      it 'has the correct name' do
        expect(fortnox_oauth2.options.name).to eq('fortnox_oauth2')
      end

      context 'when using default settings' do
        it 'has the default site set' do
          expect(fortnox_oauth2.options.client_options.site)
            .to eq('https://apps.fortnox.se')
        end

        it 'has the default token_url set' do
          expect(fortnox_oauth2.options.client_options.token_url)
            .to eq('/oauth-v1/token')
        end

        it 'has the default authorize_url set' do
          expect(fortnox_oauth2.options.client_options.authorize_url)
            .to eq('/oauth-v1/auth')
        end

        it 'has the default token_method set' do
          expect(fortnox_oauth2.options.client_options.token_method)
            .to eq(:post)
        end

        it 'has the default auth_scheme set' do
          expect(fortnox_oauth2.options.client_options.auth_scheme)
            .to eq(:basic_auth)
        end
      end

      context 'when changing client options' do
        let(:client_options) do
          {
            site: 'https://www.example.com',
            token_url: '/oauth-v2/token',
            authorize_url: '/oauth-v2/auth',
            auth_scheme: :request_body,
            token_method: :get
          }
        end

        it 'has the passed site set' do
          expect(fortnox_oauth2.options.client_options.site)
            .to eq('https://www.example.com')
        end

        it 'has the passed token_url set' do
          expect(fortnox_oauth2.options.client_options.token_url)
            .to eq('/oauth-v2/token')
        end

        it 'has the passed authorize_url set' do
          expect(fortnox_oauth2.options.client_options.authorize_url)
            .to eq('/oauth-v2/auth')
        end

        it 'has the passed auth_scheme set' do
          expect(fortnox_oauth2.options.client_options.auth_scheme)
            .to eq(:request_body)
        end

        it 'has the passed token_method set' do
          expect(fortnox_oauth2.options.client_options.token_method)
            .to eq(:get)
        end
      end
    end
  end

  describe '#callback_phase' do
    context 'when an error occurs' do
      let(:error_request) do
        double(
          'Request',
          params: { 'error_reason' => 'user_denied', 'error' => 'access_denied' }
        )
      end

      before do
        allow(fortnox_oauth2).to receive(:request) { error_request }
      end

      it 'calls fail with the client error received' do
        expect(fortnox_oauth2)
          .to receive(:fail!)
          .with('user_denied', anything)

        fortnox_oauth2.callback_phase
      end
    end
  end

  describe '#uid' do
    before do
      allow(fortnox_oauth2)
        .to receive(:raw_info)
        .and_return({ 'CompanyInformation' => { 'OrganizationNumber' => '555555-5555' } })
    end

    it 'sets the correct uid from companyinformation organization number' do
      expect(fortnox_oauth2.uid).to eq('555555-5555')
    end
  end

  describe '#credentials' do
    let(:access_token) do
      double(
        'OAuth2::AccessToken',
        token: 'abc',
        refresh_token: 'cde',
        expires_at: 1_632_830_458,
        expires?: true
      )
    end

    before do
      allow(fortnox_oauth2).to receive(:access_token).and_return(access_token)
    end

    it 'returns the correct access token' do
      expect(fortnox_oauth2.credentials['token']).to eq('abc')
    end

    it 'returns the correct refresh token' do
      expect(fortnox_oauth2.credentials['refresh_token']).to eq('cde')
    end

    it 'returns the correct expires at' do
      expect(fortnox_oauth2.credentials['expires_at']).to eq(1_632_830_458)
    end
  end

  describe '#info' do
    let(:raw_info) do
      {
        'CompanyInformation' => {
          'Address' => 'Bollvägen',
          'City' => 'Växjö',
          'CountryCode' => 'SE',
          'DatabaseNumber' => '654896',
          'CompanyName' => 'Fortnox',
          'OrganizationNumber' => '555555-5555',
          'VisitAddress' => '',
          'VisitCity' => '',
          'VisitCountryCode' => '',
          'VisitZipCode' => '',
          'ZipCode' => '35246'
        }
      }
    end

    context 'with formatted info' do
      before do
        allow(fortnox_oauth2).to receive(:raw_info).and_return(raw_info)
      end

      it 'return info without blank values' do
        expect(fortnox_oauth2.info).to eq(
          {
            'address' => 'Bollvägen',
            'city' => 'Växjö',
            'country_code' => 'SE',
            'database_number' => '654896',
            'company_name' => 'Fortnox',
            'organization_number' => '555555-5555',
            'zip_code' => '35246'
          }
        )
      end
    end

    context 'when fetchin API data' do
      let(:api_client) do
        instance_double(OmniAuth::FortnoxOAuth2::API, get: nil)
      end

      before do
        allow(fortnox_oauth2)
          .to receive(:access_token)
          .and_return(double('Bogus', token: 'abc', blank?: false))

        allow(OmniAuth::FortnoxOAuth2::API)
          .to receive(:new)
          .and_return(api_client)
      end

      it 'calls to fetch data from /companyinformation' do
        expect(api_client)
          .to receive(:get)
          .with('/companyinformation')
          .and_return(raw_info)

        fortnox_oauth2.info
      end
    end
  end

  describe '#callback_url' do
    context 'when not set in options' do
      let(:options) { { 'callback_path' => '/callback' } }
      let(:request) do
        double(
          'Request',
          scheme: 'https',
          url: '1234',
          params: { 'url' => '1234' }
        )
      end

      before do
        allow(fortnox_oauth2).to receive(:request) { request }
        allow(fortnox_oauth2).to receive(:script_name).and_return('')
      end

      it 'returns correct url from current app' do
        expect(fortnox_oauth2.callback_url).to eq('/callback')
      end
    end

    context 'when set in options' do
      it 'returns correct url from callback_url option' do
        expect(fortnox_oauth2.callback_url)
          .to eq('https://example.com/callback')
      end
    end
  end

  describe '#request_phase' do
    before do
      allow(fortnox_oauth2).to receive(:callback_url).and_return('')

      fortnox_oauth2.request_phase
    end

    it 'includes the default scope' do
      expect(fortnox_oauth2.authorize_params[:scope])
        .to eq('companyinformation')
    end

    it 'includes the response type' do
      expect(fortnox_oauth2.authorize_params[:response_type]).to eq('code')
    end

    context 'when setting scope in options' do
      let(:options) { { 'scope' => 'companyinformation,invoice' } }

      it 'uses the new scope' do
        expect(fortnox_oauth2.authorize_params[:scope])
          .to eq('companyinformation,invoice')
      end
    end
  end
end
