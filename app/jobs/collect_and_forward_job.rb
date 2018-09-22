require 'socket'

class CollectAndForwardJob < ApplicationJob
  queue_as :default

  def perform(*args)
    ud = Rails.configuration.updownio
    puts "Attempting check..."
    check = Updown::Check.get ud[:token], metrics: true
    
    reply = check.get_metrics group: :host, from: 1.hour.ago
    process_and_forward_json_object(reply)
    puts "Check done."
  end

  def process_and_forward_json_object(j)
    hg = Rails.configuration.hg
    conn = TCPSocket.new hg[:destination], hg[:port]
    puts "Received #{j.count} samples to report"
    j.each do |z|
      zone = z[0]
      timing = z[1]['timings']['total']
      conn.puts "#{hg[:key]}.response_times.#{zone} #{timing}\n"
    end
    conn.close
  end
end
