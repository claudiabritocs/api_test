require "test_helper"

class Rating::ProcessJobTest < ActiveJob::TestCase
  test "should create a job" do
    rating = Rating.new(post_id: 1, user_id: default_user, value: 4)
    
  end
end
