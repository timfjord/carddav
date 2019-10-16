# frozen_string_literal: true

require 'spec_helper'

describe Carddav do
  it 'should ensure it has version number' do
    expect(Carddav::VERSION).not_to be_nil
  end

  describe '.service' do
    it 'should raise error on unknown service' do
      expect do
        Carddav.service('unknown', 'user', 'pass')
      end.to raise_error Carddav::UnknownService
    end

    it 'should find service' do
      service = Carddav.service(:apple, 'user', 'pass')

      expect(service).to be_instance_of Carddav::Client
    end
  end
end
