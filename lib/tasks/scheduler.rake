desc "Runs the collect_and_forward job"
task :collect_and_forward => :environment do
  CollectAndForwardJob.perform_now
end

desc "Deletes old records from the DB"
task :remove_old_samples => :environment do
  RemoveOldSamples.perform_now
end