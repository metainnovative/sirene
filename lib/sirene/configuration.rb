# frozen_string_literal: true

require 'singleton'

class Sirene
  class Configuration
    include Singleton

    attr_accessor :key
    attr_accessor :secret
  end
end
