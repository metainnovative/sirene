# frozen_string_literal: true

require 'sirene/insee_server_error'
require 'sirene/paged_enumerable'

class Sirene
  class Establishment
    attr_reader :siret

    class PagedEnumerable < Sirene::PagedEnumerable
      def items
        @body_parsed[:etablissements].map do |establishment|
          Sirene::Establishment.new(establishment[:siret], data: establishment)
        end
      end
    end

    def initialize(siret, data: nil)
      @siret = siret
      @data = data
    end

    def inspect
      "#<#{self.class.name}:#{(object_id << 1).to_s(16)} siret: #{siret.inspect}>"
    end

    def fetch
      response = HTTP.get('/entreprises/sirene/V3/siret', query: { q: "siret:#{@siret}" })

      raise InseeServerError, response unless response.is_a?(Net::HTTPSuccess)

      @data = response.body_parsed[:etablissements].first
    end

    def data
      @data ||= fetch
    end

    def self.list(siren)
      PagedEnumerable.new do |query|
        response = HTTP.get('/entreprises/sirene/V3/siret', query: query.merge(q: "siren:#{siren}"))

        raise InseeServerError, response unless response.is_a?(Net::HTTPSuccess)

        response
      end
    end
  end
end
