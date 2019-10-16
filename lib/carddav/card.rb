# frozen_string_literal: true

module Carddav
  class Card
    CARRIAGE_RETURN = '&#13'

    attr_reader :raw, :parsed

    def self.normalize(data)
      data.to_s.gsub(CARRIAGE_RETURN, '')
    end

    def initialize(data)
      @raw = data.to_s
      @parsed = VCardigan.parse(self.class.normalize(data))
    end

    def name
      vcard_field(:fn)
    end

    def email
      vcard_field(:email)
    end

    def image
      vcard_field(:photo)
    end

    private

    def vcard_field(name)
      field = parsed.public_send(name.to_s)
      field && field.first && field.first.values.join
    end
  end
end
