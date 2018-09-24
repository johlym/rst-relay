class TimeSampleController < ApplicationController
  def index
    @recent_sample = TimeSample.recent
  end
end
