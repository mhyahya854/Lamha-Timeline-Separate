# frozen_string_literal: true

class Points::LiveBroadcaster
  attr_reader :user_id, :upserted_results, :payloads

  def initialize(user_id, upserted_results, payloads)
    @user_id = user_id
    @upserted_results = upserted_results
    @payloads = payloads
  end

  def call
    return if upserted_results.empty?

    user = User.find_by(id: user_id)
    return unless user

    live_map = user.safe_settings&.live_map_enabled
    active_live = SharedLink.active.where(user_id: user_id, resource_type: :live).to_a
    return if !live_map && active_live.empty?

    payloads_by_timestamp = payloads.index_by { |p| p[:timestamp].to_i }

    upserted_results.each do |result|
      payload = payloads_by_timestamp[result['timestamp'].to_i] || {}
      broadcast_points(user, result, payload) if live_map
    end

    broadcast_live_shares(user, active_live) if active_live.any?
  end

  private

  def broadcast_live_shares(user, shares)
    latest = upserted_results.max_by { |r| r['timestamp'].to_i }
    return if latest.nil?

    point = SharedLinks::LivePoint.new(
      user,
      lat: latest['latitude'],
      lon: latest['longitude'],
      timestamp: latest['timestamp']
    ).call

    shares.each { |share| SharedLocationChannel.broadcast_to(share, point) }
  end

  def broadcast_points(user, result, payload)
    PointsChannel.broadcast_to(
      user,
      [
        result['latitude'].to_f,
        result['longitude'].to_f,
        payload[:battery].to_s,
        payload[:altitude].to_s,
        result['timestamp'].to_s,
        payload[:velocity].to_s,
        result['id'].to_s,
        ''
      ]
    )
  end

end
