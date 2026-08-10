# frozen_string_literal: true

class Users::Destroy
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def call
    user_id = user.id
    user_email = user.email

    cancel_scheduled_jobs

    # Purge ActiveStorage attachments before delete_all (which bypasses callbacks)
    purge_attachments_for('Import', user.imports)
    purge_attachments_for('Export', user.exports)
    purge_attachments_for('Points::RawDataArchive', user.raw_data_archives)

    ActiveRecord::Base.transaction do
      # Delete associated records first (dependent: :destroy associations)
      # IMPORTANT: Order matters due to foreign key constraints!

      user.points.delete_all
      user.imports.delete_all
      user.stats.delete_all
      user.exports.delete_all
      user.notifications.delete_all

      # Delete place_visits BEFORE visits (place_visits has FK to visits)
      PlaceVisit.where(visit_id: user.visits.select(:id)).delete_all

      # Delete visits BEFORE areas (visits has FK to areas)
      user.visits.delete_all
      user.areas.delete_all

      user.places.delete_all

      # Delete taggings BEFORE tags (taggings has FK to tags)
      Tagging.where(tag_id: user.tags.select(:id)).delete_all
      user.tags.delete_all

      user.trips.delete_all

      # Delete track_segments and video_exports BEFORE tracks (both have FK to tracks)
      TrackSegment.where(track_id: user.tracks.select(:id)).delete_all
      delete_video_exports_for(user)
      user.tracks.delete_all

      user.raw_data_archives.delete_all
      user.digests.delete_all

      # Hard delete the user (bypasses soft-delete, skips callbacks)
      user.delete
    end

    Rails.logger.info "User #{user_id} (#{user_email}) and all associated data deleted"

    cleanup_user_cache(user_id)

    true
  end

  private

  CANCELLABLE_JOB_CLASSES = %w[
    Users::MailerSendingJob
    Users::Digests::Yearly::EmailSendingJob
    Users::Digests::Monthly::EmailSendingJob
    Users::Digests::EmailSendingJob
    Tracks::RealtimeGenerationJob
    Tracks::BoundaryResolverJob
  ].freeze

  def cancel_scheduled_jobs
    scheduled_set = Sidekiq::ScheduledSet.new

    jobs_cancelled = scheduled_set.select do |job|
      wrapped_class = job.item['wrapped']
      next false unless CANCELLABLE_JOB_CLASSES.include?(wrapped_class)

      # ActiveJob stores arguments in args[0]['arguments'], first argument is user_id
      job.args.first&.dig('arguments')&.first == user.id
    end.map(&:delete).count

    Rails.logger.info "Cancelled #{jobs_cancelled} scheduled jobs for user #{user.id}"
  rescue StandardError => e
    Rails.logger.warn "Failed to cancel scheduled jobs for user #{user.id}: #{e.message}"
    ExceptionReporter.call(e, 'Failed to cancel scheduled jobs during user deletion')
  end

  def purge_attachments_for(record_type, relation)
    ActiveStorage::Attachment
      .where(record_type: record_type, record_id: relation.select(:id))
      .find_each(&:purge)
  rescue StandardError => e
    Rails.logger.warn "Failed to purge #{record_type} attachments: #{e.message}"
    ExceptionReporter.call(e, "Failed to purge #{record_type} attachments for user #{user.id}")
  end

  # video_exports table exists (FK to tracks and users) but has no model class.
  # Use raw SQL to avoid NameError.
  def delete_video_exports_for(user)
    return unless ActiveRecord::Base.connection.table_exists?('video_exports')

    ActiveRecord::Base.connection.execute(
      ActiveRecord::Base.sanitize_sql_array(
        ['DELETE FROM video_exports WHERE user_id = ?', user.id]
      )
    )
  end

  def cleanup_user_cache(user_id)
    cache_keys = [
      "dawarich/user_#{user_id}_countries_visited",
      "dawarich/user_#{user_id}_cities_visited",
      "dawarich/user_#{user_id}_total_distance",
      "dawarich/user_#{user_id}_years_tracked"
    ]

    cache_keys.each { |key| Rails.cache.delete(key) }

    Rails.logger.info "Cleared cache for user #{user_id}"
  rescue StandardError => e
    Rails.logger.warn "Failed to clear cache for user #{user_id}: #{e.message}"
  end
end
