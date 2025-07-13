class Rating::ProcessJob < ApplicationJob
  queue_as :default

  def perform(post_id, user_id, value)
    post = Post.find(post_id)
    user = User.find(user_id)

    rating = Rating.new(post: post, user: user, value: value)
    rating.save
  end
end
