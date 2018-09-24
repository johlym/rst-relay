desc "Runs the collect_and_forward job"
task :collect_and_forward => :environment do
  CollectAndForwardJob.perform_now
end