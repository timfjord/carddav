require 'spec_helper'

describe Carddav::Url do
  describe '#new' do
    let(:url) { Carddav::Url.new 'http://test.com' }

    it 'should return passed param if absolute url detected' do
      http_url = 'http://google.com'
      https_url = 'https://google.com'
      expect(url.new(http_url).to_s).to eql http_url
      expect(url.new(https_url).to_s).to eql https_url
    end

    it 'should append path if relative url given' do
      expect(url.new('my_path').to_s).to eql 'http://test.com/my_path'
      expect(url.new('/my_path').to_s).to eql 'http://test.com/my_path'
      expect(url.new('/my_path/').to_s).to eql 'http://test.com/my_path/'
    end

    it 'should parse url and use host only for path with ending slash' do
      url = Carddav::Url.new 'http://test.com/my_path/'
      expect(url.new('new_path').to_s).to eql 'http://test.com/new_path'
      expect(url.new('/new_path').to_s).to eql 'http://test.com/new_path'
      expect(url.new('/new_path/').to_s).to eql 'http://test.com/new_path/'
    end
  end
end
