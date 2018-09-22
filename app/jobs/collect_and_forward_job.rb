require 'socket'

class CollectAndForwardJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "Attempting check..."
    check = Updown::Check.get Rails.configuration.updownio[:token], metrics: true
    
    reply = check.get_metrics group: :host, from: 1.hour.ago
    process_and_forward_json_object(reply)
    puts "Check done."
  end

  def process_and_forward_json_object(j)
    hgkey = "2ef65f36-c77e-4024-a895-d486fd7c11f2"
    conn = TCPSocket.new '3de08a3c.carbon.hostedgraphite.com', 2003
    puts "Received #{j.count} samples to report"
    j.each do |z|
      zone = z[0]
      timing = z[1]['timings']['total']
      conn.puts "#{hgkey}.response_times.#{zone} #{timing}\n"
    end
    conn.close
  end
end
