require 'test_helper'

class TimeSampleControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get time_sample_index_url
    assert_response :success
  end

end
