class CollectAndForwardJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "running the thing."
  end
end
