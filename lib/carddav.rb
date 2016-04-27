require 'curb'
require 'nokogiri'
require 'vcardigan'

require 'carddav/version'
require 'carddav/client'
require 'carddav/url'
require 'carddav/card'

module Carddav
  SERVICES = {
    apple: 'https://contacts.icloud.com',
    gmx: { host: 'https://carddav.gmx.net', urls: {
      current_user_principal: '/CardDavProxy/carddav/user-principal-uri'
    }}
  }

  class InvalidResponse < Exception
    attr_reader :response

    def initialize(msg = nil, response = nil)
      super msg
      @response = response
    end
  end

  class UnknownService < Exception
  end

  def self.service(name, username, password)
    service = SERVICES[name.to_sym] || raise(UnknownService)
    service = { host: service } unless service.is_a? Hash
    client = Client.new service[:host], username, password
    Array(service[:urls]).each do |key, value|
      client.public_send "#{key}_url=", value
    end
    client
  end
end
