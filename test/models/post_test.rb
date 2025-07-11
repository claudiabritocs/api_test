require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "Title presence is true" do
    post = Post.new(title: nil)
    assert_not post.valid?
  end
end
