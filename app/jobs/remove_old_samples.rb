require 'socket'

class RemoveOldSamples < ApplicationJob
  include Rollbar::ActiveJob
  queue_as :default

  def perform(*args)
    logger.tagged("RemoveOldSamples") do
      logger.info("Checking for old time samples.")
      data = candidates_for_deletion
      if data == nil
        logger.info("No viable records. Skipping... this time.")
        return
      end
      logger.info("Number of old records: #{data.count}. Processing.")
      candidates_for_deletion.each do |c|
          logger.info("Processing #{c.id} from #{c.created_at}")
        begin
          c.destroy!
        rescue => exception
          logger.error("Something went wrong: #{exception}")
        else
          logger.info("Done.")
        end
      end
      logger.info("Deletion complete.")
    end
  end

  def candidates_for_deletion
    job_setting = Rails.configuration.old_samples_job
    results = TimeSample.where('created_at < ?', job_setting[:max_age_days].days.ago)
    if results.empty?
      nil
    end
    results
  end
end
