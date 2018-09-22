desc "Runs the collect_and_forward job"
task :collect_and_forward => :environment do
  puts "Fetching response time data from updown.io..."
  CollectAndForwardJob.perform_now
  puts "Done."
end