require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "user_id is a valid id" do
    post = Post.new(user_id: users(:one).id)
    assert User.exists?(post.user_id)
  end

  test "Title presence is true" do
    post = Post.new(title: nil)
    assert_not post.valid?
  end

  test "Body content presence is true" do
    post = Post.new(body: nil)
    assert_not post.valid?
  end

  test "Ip presence is true" do
    post = Post.new(ip: nil)
    assert_not post.valid?
  end
end
