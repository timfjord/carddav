require 'spec_helper'

describe Carddav::Card do
  let(:data) { "BEGIN:VCARD&#13;\nN:Evie;Fjord;;;&#13;\nFN:Evie Fjord&#13;\nPHOTO;TYPE=JPEG;X-ABCROP-RECTANGLE=ABClipRect_1&amp;0&amp;0&amp;300&amp;300&amp;kAJYDeIuG6PpBcAK&#13;\n vvq6hA==;VALUE=uri:https://p02-contacts.icloud.com:443/574745797/wcs/0103f1c&#13;\n cdbde6a4ceee3826afccf55b34900b5c5a1&#13;\nEMAIL;TYPE=HOME;TYPE=pref;TYPE=INTERNET:ev@fjord.com&#13;\nVERSION:3.0&#13;\nUID:B503F97F-0D4B-4E58-A649-F30287D9DBDC&#13;\nEND:VCARD&#13;\n" }

  describe '.normalize' do
    it 'should normalize passed string' do
      normalized = Carddav::Card.normalize data

      expect(normalized).not_to include '&#13'
    end
  end

  describe '#name' do
    it 'should get name from parsed card' do
      expect(Carddav::Card.new(data).name).to eql 'Evie Fjord'
    end
  end

  describe '#email' do
    it 'should get email from parsed card' do
      expect(Carddav::Card.new(data).email).to eql 'ev@fjord.com'
    end
  end
end
