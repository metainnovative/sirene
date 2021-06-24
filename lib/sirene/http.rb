# frozen_string_literal: true

require 'base64'
require 'cgi'
require 'json'
require 'net/http'
require 'uri'

require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/to_query'
require 'active_support/core_ext/string/inflections'

require 'sirene/authentication_error'
require 'sirene/insee_server_error'

class Sirene
  class HTTP
    include Singleton

    def self.get(path, opts = {})
      instance.get(path, opts)
    end

    def get(path, opts = {})
      token = @token || refresh_session
      opts[:headers] ||= {}
      opts[:headers].merge!(authorization: "Bearer #{token}")

      request(path, :get, opts)
    end

    def refresh_session
      credentials = Base64.strict_encode64("#{Sirene.config.key}:#{Sirene.config.secret}")
      response = request(
        '/token', :post,
        payload: { grant_type: 'client_credentials' },
        headers: { authorization: "Basic #{credentials}" }
      )

      raise Sirene::AuthenticationError, response unless response.is_a?(Net::HTTPSuccess)

      @token = response.body_parsed[:access_token]
    end

    def self.json_body_transform(body)
      case body
      when Array
        body.map { |v| json_body_transform(v) }
      when Hash
        body.deep_transform_keys { |k| k.to_s.parameterize(separator: '_', preserve_case: true).underscore.to_sym }
      else
        body
      end
    end

    private

    def request(path, method, opts = {})
      http = Net::HTTP.new('api.insee.fr', 443)
      http.use_ssl = true

      uri = URI(path)
      uri.query = CGI.parse(uri.query || '').merge(opts[:query]).to_query if opts[:query].present?

      response = case method
                 when :get
                   http.get(uri.to_s, opts[:headers])
                 when :post
                   payload = case opts[:payload]
                             when Hash
                               if opts[:headers].find { |k, _| k.to_s.downcase == 'content-type' }
                                 JSON(opts[:payload])
                               else
                                 URI.encode_www_form(opts[:payload])
                               end
                             else
                               opts[:payload]
                             end

                   http.post(uri.to_s, payload, opts[:headers])
                 else
                   raise NotImplementedError, "method: #{method}"
                 end

      if opts[:json_response] || response.header['content-type'].to_s.split(';').first == 'application/json'
        response.define_singleton_method(:body_parsed) { Sirene::HTTP.json_body_transform(JSON(body)) }
      else
        response.define_singleton_method(:body_parsed) { body }
      end

      response
    end
  end
end
