require "test_helper"

class RatingTest < ActiveSupport::TestCase
  test "should not save without a valid value" do
    rating = Rating.new(user_id: users(:one).id, post_id: posts(:one).id, value: 6)
    assert_not rating.valid?
    assert_includes rating.errors[:value], "must be less than or equal to 5"
  end

  test "should not save if post_id isn't a valid id" do
    rating = Rating.new(user_id: users(:one).id, post_id: -1, value: 4)
    assert_not rating.valid?
    assert_includes rating.errors[:post], "must exist"
  end


end