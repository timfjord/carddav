# frozen_string_literal: true

module Carddav
  class Client
    NAMESPACES = { 'xmlns:D' => 'DAV:', 'xmlns:C' => 'urn:ietf:params:xml:ns:carddav' }

    attr_reader :host, :username, :password

    def initialize(host, username, password)
      @host = Carddav::Url.new host
      @username = username
      @password = password
    end

    def current_user_principal_url=(url)
      @current_user_principal_url = host.new(url)
    end

    def addressbook_home_set_url=(url)
      @addressbook_home_set_url = host.new(url)
    end

    def addressbook_url=(url)
      @addressbook_url = host.new(url)
    end

    def current_user_principal_url
      @current_user_principal_url ||= find_href(host, 'D:current-user-principal')
    end

    def addressbook_home_set_url
      @addressbook_home_set_url ||= find_href(current_user_principal_url, 'C:addressbook-home-set')
    end

    def addressbook_url
      @addressbook_url ||= find_href addressbook_home_set_url, 'D:resourcetype', 1 do |xml|
        xml.xpath('//response/href[following-sibling::propstat/prop/resourcetype/addressbook]')
      end
    end

    def cards
      res = request addressbook_url, method: 'REPORT', depth: 1 do
        Nokogiri::XML::Builder.new do |xml|
          xml['C'].send 'addressbook-query', NAMESPACES do
            xml['D'].prop do
              xml['D'].getetag
              xml['C'].send('address-data')
            end
          end
        end.to_xml
      end
      res.xpath('//address-data/text()').map { |node| Carddav::Card.new node }
    end

    private

    def request(url, method: 'PROPFIND', depth: 0)
      req = Curl::Easy.perform url.to_s do |c|
        c.headers['Content-Type'] = 'application/xml'
        c.headers['Depth'] = depth
        c.userpwd = "#{username}:#{password}"
        c.set :customrequest, method
        c.set :postfields, yield if block_given?
      end

      if (status = /^(\d+)/.match(req.status)[0].to_i) && (status < 200 || status >= 300)
        raise Carddav::InvalidResponse, "Invalid response from #{url}", req.body_str
      end

      Nokogiri::XML(req.body_str).remove_namespaces!
    end

    def find_href(url, node, depth = 0)
      namespece, node_name = node.split(':')

      res = request url, depth: depth do
        Nokogiri::XML::Builder.new do |xml|
          xml['D'].propfind NAMESPACES do
            xml['D'].prop do
              xml[namespece].send(node_name)
            end
          end
        end.to_xml
      end
      el = block_given? ? yield(res) : res.css("#{node_name} href")

      if el.empty?
        raise(Carddav::InvalidResponse, "Cannot find #{node_name} node", res.to_xml)
      end

      url.new(el.first.text)
    end
  end
end
