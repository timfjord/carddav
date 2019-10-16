# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'url finder' do |method|
  it 'should raise error when status is wrong' do
    stub_request(:get, host).to_return(
      headers: { 'HTTP/1.1 400 Bad' => '' }
    )
    expect { client.send(method) }.to raise_error Carddav::InvalidResponse
  end

  it 'should raise error when body is invliad' do
    stub_request(:get, host).to_return(body: '')
    expect { client.send(method) }.to raise_error Carddav::InvalidResponse
  end

  it 'should find url from response' do
    stub_request(:get, host).to_return(body: body)

    expect(client.send(method).to_s).to eql url
  end
end

describe Carddav::Client do
  let(:host) { 'http://test.com' }

  describe 'contructor' do
    it 'should set variables' do
      client = described_class.new(host, 'username', 'password')

      expect(client.host).to be_kind_of Carddav::Url
      expect(client.username).to eql 'username'
      expect(client.password).to eql 'password'
    end
  end

  describe 'url setters' do
    let(:client) { described_class.new(host, 'username', 'password') }

    it 'should set url and append to host if needed' do
      %i(current_user_principal_url addressbook_home_set_url addressbook_url).each do |method|
        client.public_send("#{method}=", '/path')
        expect(client.send(method).to_s).to eql 'http://test.com/path'

        client.public_send("#{method}=", 'http://new.test.com/new_path')
        expect(client.send(method).to_s).to eql 'http://new.test.com/new_path'
      end
    end
  end

  describe 'url getters' do
    let(:client) { described_class.new(host, 'username', 'password') }

    describe '#current_user_principal_url' do
      let(:url) { 'http://current.user/principal/url' }
      let(:body) { '<?xml version="1.0" encoding="UTF-8" standalone="no"?><D:multistatus xmlns:D="DAV:"><D:response><D:href>/</D:href><D:propstat><D:prop><D:current-user-principal><D:href>' + url + '</D:href></D:current-user-principal></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response></D:multistatus>' }

      it_behaves_like 'url finder', :current_user_principal_url
    end

    describe '#addressbook_home_set_url' do
      let(:url) { 'http://addressbook.home/set/url' }
      let(:body) { '<?xml version="1.0" encoding="UTF-8" standalone="no"?><D:multistatus xmlns:D="DAV:"><D:response><D:href>/CardDavProxy/carddav/user-principal-uri</D:href><D:propstat><D:prop><C:addressbook-home-set xmlns:C="urn:ietf:params:xml:ns:carddav"><D:href>' + url + '</D:href></C:addressbook-home-set></D:prop><D:status>HTTP/1.1 200 OK</D:status></D:propstat></D:response></D:multistatus>' }

      before :each do
        client.current_user_principal_url = host
      end

      it_behaves_like 'url finder', :addressbook_home_set_url
    end

    describe '#addressbook_url' do
      let(:url) { 'http://addressbook.url/url/url' }
      let(:body) { '<?xml version="1.0" encoding="UTF-8" standalone="yes"?> <multistatus xmlns="DAV:"> <response> <href>/url/carddavhome/</href> <propstat> <prop> <resourcetype><collection/></resourcetype> </prop> <status>HTTP/1.1 200 OK</status> </propstat> <propstat> <prop> <displayname/> </prop> <status>HTTP/1.1 404 Not Found</status> </propstat> </response> <response> <href>' + url + '</href> <propstat> <prop> <resourcetype> <addressbook xmlns="urn:ietf:params:xml:ns:carddav"/><collection/> </resourcetype> </prop> <status>HTTP/1.1 200 OK</status> </propstat> <propstat> <prop> <displayname/> </prop> <status>HTTP/1.1 404 Not Found</status> </propstat> </response> </multistatus>' }

      before :each do
        client.addressbook_home_set_url = host
      end

      it_behaves_like 'url finder', :addressbook_url
    end
  end

  describe '#cards' do
    let(:client) { described_class.new(host, 'username', 'password') }
    let(:body) { "<?xml version=\"1.0\" encoding=\"UTF-8\"?> <multistatus xmlns=\"DAV:\" xmlns:CD=\"urn:ietf:params:xml:ns:carddav\" xmlns:CS=\"http://calendarserver.org/ns/\"> <response> <href>/234234/carddavhome/card/1111.vcf</href> <propstat> <prop> <getetag>\"C=4@U=cc792711-9684-4d3f-a3aa-1db18cf1c8a8\"</getetag> <address-data xmlns=\"urn:ietf:params:xml:ns:carddav\">BEGIN:VCARD&#13;\nN:Evie;Fjord;;;&#13;\nFN:Evie Fjord&#13;\nPHOTO;TYPE=JPEG;X-ABCROP-RECTANGLE=ABClipRect_1&amp;0&amp;0&amp;300&amp;300&amp;kAJYDeIuG6PpBcAK&#13;\n vvq6hA==;VALUE=uri:https://p02-contacts.icloud.com:443/574745797/wcs/0103f1c&#13;\n cdbde6a4ceee3826afccf55b34900b5c5a1&#13;\nEMAIL;TYPE=HOME;TYPE=pref;TYPE=INTERNET:ev@fjord.com&#13;\nVERSION:3.0&#13;\nUID:B503F97F-0D4B-4E58-A649-F30287D9DBDC&#13;\nEND:VCARD&#13;\n</address-data> </prop> <status>HTTP/1.1 200 OK</status> </propstat> </response> </multistatus>" }

    it 'should raise error when status is wrong' do
      stub_request(:get, host).to_return(
        headers: { 'HTTP/1.1 400 Bad' => '' }
      )

      expect { client.cards }.to raise_error Carddav::InvalidResponse
    end

    it 'should raise error when body is invliad' do
      stub_request(:get, host).to_return body: ''

      expect { client.cards }.to raise_error Carddav::InvalidResponse
    end

    it 'should return cards' do
      client.addressbook_url = host
      stub_request(:get, host).to_return(body: body)

      cards = client.cards

      expect(cards.size).to eql 1
      card = cards.first
      expect(card).to be_instance_of Carddav::Card
      expect(card.name).to eql 'Evie Fjord'
      expect(card.email).to eql 'ev@fjord.com'
    end
  end
end
