require "test_helper"

class RatingTest < ActiveSupport::TestCase
  fixtures :users, :posts, :ratings

  test "should not save without a valid value" do
    rating = Rating.new(user_id: users(:one).id, post_id: posts(:one).id, value: 6)
    assert_not rating.valid?
    assert_includes rating.errors[:value], "must be less than or equal to 5"
  end

  test "should not save if value is blank" do
    rating = Rating.new(user_id: users(:one).id, post_id: posts(:one).id, value: "")
    assert_not rating.valid?
    assert_includes rating.errors[:value], "can't be blank"
  end

  test "should not save if user_id is blank" do
    rating = Rating.new(user_id: "", post_id: posts(:one).id, value: "")
    assert_not rating.valid?
    assert_includes rating.errors[:user], "can't be blank"
  end

  test "should not accept more than 1 rating to a post from same user" do
    _rating = Rating.create!(user: users(:default_user), post_id: posts(:one).id, value: 2)

    duplicate_rating = Rating.new(user: users(:default_user), post_id: posts(:one).id, value: 2)

    duplicate_rating.valid?

    assert_includes duplicate_rating.errors[:user_id], "has already rated this post"
  end

  test "should not save if user_id isn't a valid id" do
    rating = Rating.new(user_id: "0998987378357", post_id: 1, value: 3)
    assert_not rating.valid?
    assert_includes rating.errors[:user], "must exist"
  end

  test "should not save if post_id isn't a valid id" do
    rating = Rating.new(user_id: users(:one).id, post_id: -1, value: 4)
    assert_not rating.valid?
    assert_includes rating.errors[:post], "must exist"
  end

  test "should not save if post_id is blank" do
    rating = Rating.new(user_id: users(:one).id, post_id: "", value: "")
    assert_not rating.valid?
    assert_includes rating.errors[:post], "can't be blank"
  end
end
