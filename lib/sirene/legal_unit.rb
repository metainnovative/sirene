# frozen_string_literal: true

require 'sirene/establishment'
require 'sirene/insee_server_error'

class Sirene
  class LegalUnit
    attr_reader :siren

    def initialize(siren)
      @siren = siren
    end

    def inspect
      "#<#{self.class.name}:#{(object_id << 1).to_s(16)} siren: #{siren.inspect}>"
    end

    def fetch
      response = HTTP.get('/entreprises/sirene/V3/siren', query: { q: "siren:#{@siren}" })

      raise InseeServerError, response unless response.is_a?(Net::HTTPSuccess)

      @data = response.body_parsed[:unites_legales].first
    end

    def data
      @data ||= fetch
    end

    def establishments
      Establishment.list(siren)
    end
  end
end
