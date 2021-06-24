# frozen_string_literal: true

require 'active_support/core_ext/object/blank'

class Sirene
  class PagedEnumerable
    include Enumerable

    def initialize(&block)
      @block = block
    end

    def inspect
      "#<#{self.class.name}:#{(object_id << 1).to_s(16)}>"
    end

    def each
      query = { nombre: 20 }
      loop do
        @body_parsed = @block.call(query).body_parsed
        items.each { |i| yield i }
        query[:curseur] = @body_parsed[:header][:curseurSuivant]
        break if query[:curseur].blank?
      end
    end

    def items
      raise NotImplementedError
    end
  end
end
