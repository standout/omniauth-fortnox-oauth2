# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    # Fortnox
    class FortnoxOauth2 < OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = 'companyinformation'

      option :name, 'fortnox_oauth2'

      option :client_options, {
        site: 'https://apps.fortnox.se',
        token_url: '/oauth-v1/token',
        authorize_url: '/oauth-v1/auth',
        auth_scheme: :basic_auth,
        token_method: :post
      }

      option :authorize_options, %i[scope state account_type]
      option :provider_ignores_state, false

      uid { raw_info['CompanyInformation']['OrganizationNumber'] }

      info do
        prune!(
          'address' => raw_info['CompanyInformation']['Address'],
          'city' => raw_info['CompanyInformation']['City'],
          'country_code' => raw_info['CompanyInformation']['CountryCode'],
          'database_number' => raw_info['CompanyInformation']['DatabaseNumber'],
          'company_name' => raw_info['CompanyInformation']['CompanyName'],
          'organization_number' => raw_info['CompanyInformation']['OrganizationNumber'],
          'visit_address' => raw_info['CompanyInformation']['VisitAddress'],
          'visit_city' => raw_info['CompanyInformation']['VisitCity'],
          'visit_country_code' => raw_info['CompanyInformation']['VisitCountryCode'],
          'visit_zip_code' => raw_info['CompanyInformation']['VisitZipCode'],
          'zip_code' => raw_info['CompanyInformation']['ZipCode']
        )
      end

      extra do
        hash = {}
        hash['raw_info'] = raw_info unless skip_info?
        prune! hash
      end

      def raw_info
        return if access_token.blank?

        api_client = OmniAuth::FortnoxOAuth2::API.new(access_token&.token)
        @raw_info ||= api_client.get('/companyinformation')
      end

      def request_phase
        options[:authorize_params] = {
          client_id: options['client_id'],
          response_type: 'code',
          scope: (options['scope'] || DEFAULT_SCOPE)
        }.merge( options['account_type'] ? { account_type: options['account_type'] } : {} )

        super
      end

      def callback_url
        options[:callback_url] || (full_host + script_name + callback_path)
      end

      def build_access_token
        verifier = request.params['code']
        client.auth_code.get_token(
          verifier,
          { redirect_uri: callback_url }.merge(token_params.to_hash(symbolize_keys: true)),
          deep_symbolize(options.auth_token_params)
        )
      end

      private

      def prune!(hash)
        hash.delete_if do |_, value|
          prune!(value) if value.is_a?(Hash)
          value.nil? || (value.respond_to?(:empty?) && value.empty?)
        end
      end
    end
  end
end
