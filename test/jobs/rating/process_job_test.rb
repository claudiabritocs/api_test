require "test_helper"

class Rating::ProcessJobTest < ActiveJob::TestCase
  fixtures :users, :posts

  test "should create a rating with valid user and post" do
    assert_difference("Rating.count", 1) do
      Rating::ProcessJob.perform_now(posts(:one).id, users(:default_user).id, 4)
    end

    rating = Rating.last
    assert_equal posts(:one).id, rating.post_id
    assert_equal users(:default_user).id, rating.user_id
    assert_equal 4, rating.value
  end

  test "should not create a duplicate rating" do
    Rating.create!(post: posts(:one), user: users(:default_user), value: 5)

    assert_no_difference("Rating.count") do
      Rating::ProcessJob.perform_now(posts(:one).id, users(:default_user).id, 3)
    end
  end

  test "should not create rating if user or post does not exist" do
    assert_no_difference("Rating.count") do
      Rating::ProcessJob.perform_now(-1, -1, 3)
    end
  end
end
