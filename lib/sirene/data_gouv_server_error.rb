# frozen_string_literal: true

class Sirene
  class DataGouvServerError < StandardError
    attr_reader :response

    def initialize(response)
      @response = response
      super
    end
  end
end
