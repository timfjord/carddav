# frozen_string_literal: true

module Carddav
  class Url
    ABSOLUTE_URL = %r{^https?:\/\/}.freeze

    def initialize(uri)
      @uri = URI uri
    end

    def new(path)
      return self.class.new(path) if ABSOLUTE_URL =~ path

      uri = @uri.dup
      uri.path = path.start_with?('/') ? path : "/#{path}"

      self.class.new(uri)
    end

    def to_s
      @uri.to_s
    end
  end
end
