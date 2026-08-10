# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DawarichSettings do
  describe '.features_for' do
    it 'reports reverse geocoding availability for the given user' do
      allow(described_class).to receive(:reverse_geocoding_enabled?).and_return(true)

      expect(described_class.features_for(create(:user))[:reverse_geocoding]).to be true
    end
  end
end
