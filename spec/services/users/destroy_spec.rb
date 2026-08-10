# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::Destroy do
  describe '#call' do
    let(:user) { create(:user) }
    let(:service) { described_class.new(user) }

    before do
      user.mark_as_deleted!
    end

    context 'with minimal user data' do
      it 'hard deletes the user record' do
        expect { service.call }.to change { User.unscoped.count }.by(-1)
      end

      it 'returns true on success' do
        expect(service.call).to be true
      end

      it 'logs the deletion' do
        allow(Rails.logger).to receive(:info)

        service.call

        expect(Rails.logger).to have_received(:info).with(/User \d+ \(.+\) and all associated data deleted/)
      end
    end

    context 'with associated records without foreign key constraints' do
      let!(:points) { create_list(:point, 5, user:) }
      let!(:import) { create(:import, user:) }
      let!(:stat) { create(:stat, user:, year: 2024, month: 1) }
      let!(:place) { create(:place, user:) }
      let!(:trip) { create(:trip, user:) }
      let!(:notification) { create(:notification, user:) }

      it 'deletes all points' do
        user_id = user.id
        service.call
        expect(Point.where(user_id: user_id).count).to eq(0)
      end

      it 'deletes all imports' do
        user_id = user.id
        service.call
        expect(Import.where(user_id: user_id).count).to eq(0)
      end

      it 'deletes all stats' do
        user_id = user.id
        service.call
        expect(Stat.where(user_id: user_id).count).to eq(0)
      end

      it 'deletes all places' do
        user_id = user.id
        service.call
        expect(Place.where(user_id: user_id).count).to eq(0)
      end

      it 'deletes all trips' do
        user_id = user.id
        service.call
        expect(Trip.where(user_id: user_id).count).to eq(0)
      end

      it 'deletes all notifications' do
        user_id = user.id
        service.call
        expect(Notification.where(user_id: user_id).count).to eq(0)
      end

      it 'performs all deletions in a transaction' do
        # Mock error before user deletion
        allow(Rails.logger).to receive(:info)
        allow(Rails.logger).to receive(:error)
        allow(ExceptionReporter).to receive(:call)
        allow_any_instance_of(described_class).to receive(:cancel_scheduled_jobs)
        allow(Point).to receive(:where).and_call_original

        # This will cause the transaction to fail
        allow(user).to receive(:delete).and_raise(StandardError, 'Database error')

        expect { service.call }.to raise_error(StandardError)
      end
    end

    context 'with scheduled jobs' do
      it 'attempts to cancel scheduled jobs for the user' do
        allow(Rails.logger).to receive(:info)

        service.call

        expect(Rails.logger).to have_received(:info).with(/Cancelled \d+ scheduled jobs for user #{user.id}/)
      end

      describe 'CANCELLABLE_JOB_CLASSES' do
        it 'lists only constants that resolve at runtime (no stale class names)' do
          described_class::CANCELLABLE_JOB_CLASSES.each do |class_name|
            expect { class_name.constantize }.not_to(
              raise_error,
              "Expected #{class_name} to constantize, but it does not exist."
            )
          end
        end

        it 'includes both the monthly and yearly digest email-sending jobs' do
          expect(described_class::CANCELLABLE_JOB_CLASSES).to include(
            'Users::Digests::Yearly::EmailSendingJob',
            'Users::Digests::Monthly::EmailSendingJob'
          )
        end
      end

      context 'when both monthly and yearly digest email jobs are scheduled for the user' do
        before do
          Sidekiq.redis { |conn| conn.del('schedule') }
          Sidekiq.redis do |conn|
            conn.zadd(
              'schedule',
              1.day.from_now.to_f,
              {
                'class' => 'ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper',
                'wrapped' => 'Users::Digests::Monthly::EmailSendingJob',
                'queue' => 'mailers',
                'args' => [{ 'job_class' => 'Users::Digests::Monthly::EmailSendingJob',
                             'arguments' => [user.id, 2026, 3] }]
              }.to_json
            )
            conn.zadd(
              'schedule',
              1.day.from_now.to_f,
              {
                'class' => 'ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper',
                'wrapped' => 'Users::Digests::Yearly::EmailSendingJob',
                'queue' => 'mailers',
                'args' => [{ 'job_class' => 'Users::Digests::Yearly::EmailSendingJob',
                             'arguments' => [user.id, 2025] }]
              }.to_json
            )
          end
        end

        after do
          Sidekiq.redis { |c| c.del('schedule') }
        end

        it 'cancels both jobs from the scheduled set' do
          expect(Sidekiq::ScheduledSet.new.size).to eq(2)

          service.call

          expect(Sidekiq::ScheduledSet.new.size).to eq(0)
        end
      end

      context 'when job cancellation fails' do
        before do
          allow(Sidekiq::ScheduledSet).to receive(:new).and_raise(StandardError, 'Redis error')
        end

        it 'logs a warning but continues deletion' do
          allow(Rails.logger).to receive(:warn)
          allow(Rails.logger).to receive(:info)
          allow(Rails.logger).to receive(:error)
          allow(ExceptionReporter).to receive(:call)

          expect { service.call }.not_to raise_error

          expect(Rails.logger).to have_received(:warn).with(/Failed to cancel scheduled jobs/)
          expect(ExceptionReporter).to have_received(:call)
        end
      end
    end

    context 'with cache cleanup' do
      before do
        # Populate cache with user data
        Rails.cache.write("dawarich/user_#{user.id}_countries_visited", %w[US CA])
        Rails.cache.write("dawarich/user_#{user.id}_cities_visited", %w[NYC SF])
        Rails.cache.write("dawarich/user_#{user.id}_total_distance", 1000)
        Rails.cache.write("dawarich/user_#{user.id}_years_tracked", [2023, 2024])
      end

      it 'clears all user-specific cache keys' do
        service.call

        expect(Rails.cache.read("dawarich/user_#{user.id}_countries_visited")).to be_nil
        expect(Rails.cache.read("dawarich/user_#{user.id}_cities_visited")).to be_nil
        expect(Rails.cache.read("dawarich/user_#{user.id}_total_distance")).to be_nil
        expect(Rails.cache.read("dawarich/user_#{user.id}_years_tracked")).to be_nil
      end

      it 'logs cache cleanup' do
        allow(Rails.logger).to receive(:info)

        service.call

        expect(Rails.logger).to have_received(:info).with("Cleared cache for user #{user.id}")
      end

      context 'when cache cleanup fails' do
        before do
          allow(Rails.cache).to receive(:delete).and_raise(StandardError, 'Cache error')
        end

        it 'logs a warning but completes deletion' do
          allow(Rails.logger).to receive(:warn)

          expect { service.call }.not_to raise_error

          expect(Rails.logger).to have_received(:warn).with(/Failed to clear cache/)
        end
      end
    end

    context 'with areas and visits (foreign key constraint)' do
      let!(:area) { create(:area, user:) }
      let!(:visit) { create(:visit, user:, area:) }

      it 'deletes visits before areas to respect foreign key constraints' do
        user_id = user.id
        area_id = area.id
        visit_id = visit.id

        service.call

        # Both should be deleted successfully
        expect(Visit.where(id: visit_id).count).to eq(0)
        expect(Area.where(id: area_id).count).to eq(0)
        expect(User.unscoped.where(id: user_id).count).to eq(0)
      end
    end

    context 'with place_visits referencing visits (foreign key constraint)' do
      let!(:area) { create(:area, user:) }
      let!(:place) { create(:place, user:) }
      let!(:visit) { create(:visit, user:, area:) }
      let!(:place_visit) { create(:place_visit, place:, visit:) }

      it 'deletes place_visits before visits to respect foreign key constraints' do
        place_visit_id = place_visit.id
        visit_id = visit.id

        service.call

        expect(PlaceVisit.where(id: place_visit_id).count).to eq(0)
        expect(Visit.where(id: visit_id).count).to eq(0)
      end
    end

    context 'when deletion fails' do
      before do
        allow(user.points).to receive(:delete_all).and_raise(StandardError, 'Database constraint violation')
      end

      it 'lets the exception propagate to the caller' do
        expect { service.call }.to raise_error(StandardError, 'Database constraint violation')
      end
    end

    context 'with ActiveStorage attachments' do
      let!(:import_record) { create(:import, user:) }

      before do
        import_record.file.attach(
          io: StringIO.new('test'),
          filename: 'test.gpx',
          content_type: 'application/gpx+xml'
        )
      end

      it 'purges attachment blobs' do
        blob = import_record.file.blob

        service.call

        expect(ActiveStorage::Blob.exists?(blob.id)).to be false
      end

      context 'when attachment purging fails' do
        before do
          allow(ActiveStorage::Attachment).to receive(:where).and_raise(StandardError, 'S3 unavailable')
        end

        it 'reports the exception and continues deletion' do
          allow(Rails.logger).to receive(:warn)
          allow(Rails.logger).to receive(:info)
          allow(ExceptionReporter).to receive(:call)

          expect { service.call }.not_to raise_error

          expect(Rails.logger).to have_received(:warn).with(/Failed to purge Import attachments/)
          expect(ExceptionReporter).to have_received(:call).with(
            instance_of(StandardError),
            /Failed to purge Import attachments/
          )
        end
      end
    end

    context 'with taggings referencing tags (foreign key constraint)' do
      let!(:tag) { create(:tag, user:) }
      let!(:place) { create(:place, user:) }
      let!(:tagging) { create(:tagging, tag:, taggable: place) }

      it 'deletes taggings before tags to respect foreign key constraints' do
        user_id = user.id
        tag_id = tag.id
        tagging_id = tagging.id

        service.call

        expect(Tagging.where(id: tagging_id).count).to eq(0)
        expect(Tag.where(id: tag_id).count).to eq(0)
        expect(User.unscoped.where(id: user_id).count).to eq(0)
      end
    end

    context 'with track_segments referencing tracks (foreign key constraint)' do
      let!(:track) { create(:track, user:) }
      let!(:segment) { create(:track_segment, track:) }

      it 'deletes track_segments before tracks to respect foreign key constraints' do
        user_id = user.id
        track_id = track.id
        segment_id = segment.id

        service.call

        expect(TrackSegment.where(id: segment_id).count).to eq(0)
        expect(Track.where(id: track_id).count).to eq(0)
        expect(User.unscoped.where(id: user_id).count).to eq(0)
      end
    end

    context 'with large datasets' do
      before do
        # Create many points to simulate a real user with lots of data
        create_list(:point, 100, user:)
      end

      it 'successfully deletes all records' do
        expect { service.call }.to change { Point.where(user_id: user.id).count }.from(100).to(0)
      end

      it 'completes deletion' do
        service.call

        expect(Point.where(user_id: user.id).count).to eq(0)
        expect(User.unscoped.find_by(id: user.id)).to be_nil
      end
    end
  end
end
