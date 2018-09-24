require 'socket'

class CollectAndForwardJob < ApplicationJob
  include Rollbar::ActiveJob
  queue_as :default

  def perform(*args)
    logger.tagged("CollectAndForward") do
      ud = Rails.configuration.updownio
      logger.info("Attempting check...")
      check = Updown::Check.get ud[:token], metrics: true
      
      reply = check.get_metrics group: :host, from: 1.hour.ago
      process_and_forward_json_object(reply)
      logger.info("Check done.")
    end
  end

  def process_and_forward_json_object(j)
    hg = Rails.configuration.hg
    conn = TCPSocket.new hg[:destination], hg[:port]
    logger.info("Received #{j.count} samples to report")
    j.each do |z|
      zone = z[0]
      timing = z[1]['timings']['total']
      conn.puts "#{hg[:key]}.response_times.#{zone} #{timing}\n"
      save_event_to_database(zone, timing)
    end
    conn.close
  end

  def save_event_to_database(zone, timing)
    ts = TimeSample.new
    ts.location = zone
    ts.value = timing
    ts.save!
    return
  end
end
