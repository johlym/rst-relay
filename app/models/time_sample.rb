class TimeSample < ApplicationRecord
  def self.recent
    return TimeSample.last(8)
  end
end
