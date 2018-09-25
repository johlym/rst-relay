require 'socket'

class CollectAndForwardJob < ApplicationJob
  include Rollbar::ActiveJob
  queue_as :default

  def perform(*args)
    ud = Rails.configuration.updownio
    logger.info("Attempting check...")
    begin
      check = Updown::Check.get ud[:token], metrics: true
      reply = check.get_metrics group: :host, from: 1.hour.ago
      process_and_forward_json_object(reply)
    rescue => exception
      logger.error("Updown check failed: #{exception}")
    ensure
      logger.info("Attempt complete.")
    end
  end

  def process_and_forward_json_object(j)
    hg = Rails.configuration.hg
    logger.info("Attempting Process and Forward...")
    begin
      conn = TCPSocket.new hg[:destination], hg[:port]
      logger.info("Received #{j.count} samples to report")
      j.each do |z|
        zone = z[0]
        timing = z[1]['timings']['total']
        conn.puts "#{hg[:key]}.response_times.#{zone} #{timing}\n"
        logger.info("Saving to local DB...")
        save_event_to_database(zone, timing)
      end
      conn.close
    rescue => exception
      logger.error("Push to HG failed: #{exception}")
    ensure
      logger.info("Attempted Process and Forward complete.")
    end
    
    
  end

  def save_event_to_database(zone, timing)
    ts = TimeSample.new
    ts.location = zone
    ts.value = timing
    ts.save!
    return
  end
end
