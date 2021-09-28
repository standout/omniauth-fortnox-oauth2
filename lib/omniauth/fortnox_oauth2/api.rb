# frozen_string_literal: true

require 'net/http'
require 'net/https'
require 'uri'

module OmniAuth
  module FortnoxOAuth2
    # API
    class API
      class Error < StandardError; end

      def initialize(token)
        @access_token = token
        @base_uri = 'https://api.fortnox.se/3'
      end

      def get(url)
        uri = URI([@base_uri, url].join(''))
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = build_request(uri)
        response = http.request(request)
        raise Error, "#{response.code}: #{response.body}" unless response.code == '200'

        JSON.parse(response.body)
      end

      private

      def build_request(uri)
        request = Net::HTTP::Get.new(uri)
        request['Authorization'] = "Bearer #{@access_token}"
        request['Content-Type'] = 'application/json'
        request['Accept'] = 'application/json'

        request
      end
    end
  end
end
