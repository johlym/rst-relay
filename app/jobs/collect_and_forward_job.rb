require 'net/http'

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
    ['tok', 'lan', 'gra', 'fra', 'bhs', 'sin', 'mia', 'syd'].each do |z|
      timing_value = j[z]["timings"]["total"]
      puts "Reporting: Zone #{z} has value: #{timing_value}"
      Keen.publish(:response_times, {
        :location => z,
        :value => timing_value
      })
      puts "Done."
    end
    
  end
end
