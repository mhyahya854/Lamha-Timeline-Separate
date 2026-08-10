# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Points::LiveBroadcaster do
  let(:user) { create(:user) }

  let(:upserted_results) do
    [
      { 'id' => 1, 'timestamp' => 1_700_000_000, 'latitude' => 52.52, 'longitude' => 13.405 }
    ]
  end

  let(:payloads) do
    [
      { timestamp: 1_700_000_000, battery: 85, altitude: 100, velocity: '5.0' }
    ]
  end

  describe '#call' do
    context 'when live_map_enabled is true' do
      before do
        user.settings['live_map_enabled'] = true
        user.save!
      end

      it 'broadcasts point data to PointsChannel' do
        expect(PointsChannel).to receive(:broadcast_to).with(
          user,
          [52.52, 13.405, '85', '100', '1700000000', '5.0', '1', '']
        )

        described_class.new(user.id, upserted_results, payloads).call
      end
    end

    context 'when live_map_enabled is false' do
      before do
        user.settings['live_map_enabled'] = false
        user.save!
      end

      it 'does not broadcast to PointsChannel' do
        expect(PointsChannel).not_to receive(:broadcast_to)

        described_class.new(user.id, upserted_results, payloads).call
      end
    end

    context 'when upserted_results is empty' do
      it 'does not broadcast' do
        expect(PointsChannel).not_to receive(:broadcast_to)

        described_class.new(user.id, [], payloads).call
      end
    end

    context 'when user does not exist' do
      it 'does not broadcast' do
        expect(PointsChannel).not_to receive(:broadcast_to)

        described_class.new(-1, upserted_results, payloads).call
      end
    end

    context 'with multiple points' do
      let(:upserted_results) do
        [
          { 'id' => 1, 'timestamp' => 1_700_000_000, 'latitude' => 52.52, 'longitude' => 13.405 },
          { 'id' => 2, 'timestamp' => 1_700_000_060, 'latitude' => 52.53, 'longitude' => 13.41 }
        ]
      end

      let(:payloads) do
        [
          { timestamp: 1_700_000_000, battery: 85, altitude: 100, velocity: '5.0' },
          { timestamp: 1_700_000_060, battery: 80, altitude: 110, velocity: '10.0' }
        ]
      end

      before do
        user.settings['live_map_enabled'] = true
        user.save!
      end

      it 'broadcasts each point' do
        expect(PointsChannel).to receive(:broadcast_to).twice

        described_class.new(user.id, upserted_results, payloads).call
      end
    end

    context 'when payload has no matching timestamp' do
      before do
        user.settings['live_map_enabled'] = true
        user.save!
      end

      let(:payloads) { [{ timestamp: 9_999_999_999, battery: 50, altitude: 0, velocity: '0' }] }

      it 'broadcasts with empty strings for missing fields' do
        expect(PointsChannel).to receive(:broadcast_to).with(
          user,
          [52.52, 13.405, '', '', '1700000000', '', '1', '']
        )

        described_class.new(user.id, upserted_results, payloads).call
      end
    end

    context 'with an active live share' do
      let!(:live_share) { create(:shared_link, :live, user: user) }

      before do
        user.settings['live_map_enabled'] = false
        user.save!
      end

      it 'broadcasts the latest point to the live share even when live_map is off' do
        expect(SharedLocationChannel).to receive(:broadcast_to).with(
          live_share, { lat: 52.52, lon: 13.405, ts: 1_700_000_000 }
        )

        described_class.new(user.id, upserted_results, payloads).call
      end

      it 'broadcasts only the single latest point for a batch of upserts' do
        multi = [
          { 'id' => 1, 'timestamp' => 1_700_000_000, 'latitude' => 52.52, 'longitude' => 13.405 },
          { 'id' => 2, 'timestamp' => 1_700_000_060, 'latitude' => 52.53, 'longitude' => 13.41 }
        ]

        expect(SharedLocationChannel).to receive(:broadcast_to).once.with(
          live_share, { lat: 52.53, lon: 13.41, ts: 1_700_000_060 }
        )

        described_class.new(user.id, multi, payloads).call
      end

      it 'masks a live point inside a privacy zone' do
        home = create(:place, user: user, latitude: 52.52, longitude: 13.405)
        tag = create(:tag, user: user, privacy_radius_meters: 500)
        create(:tagging, tag: tag, taggable: home)

        expect(SharedLocationChannel).to receive(:broadcast_to).with(live_share, { masked: true })

        described_class.new(user.id, upserted_results, payloads).call
      end
    end

    context 'with no active live share' do
      before do
        user.settings['live_map_enabled'] = false
        user.save!
      end

      it 'does not broadcast to SharedLocationChannel' do
        expect(SharedLocationChannel).not_to receive(:broadcast_to)

        described_class.new(user.id, upserted_results, payloads).call
      end
    end
  end
end
