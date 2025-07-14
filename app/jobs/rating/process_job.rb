class Rating::ProcessJob < ApplicationJob
  queue_as :default

  def perform(post_id, user_id, value)
    post = Post.find_by(id: post_id)
    user = User.find_by(id: user_id)

    unless post && user
      Rails.logger.warn("[Rating::ProcessJob] Post or User not found. post_id=#{post_id}, ser_id=#{user_id}")
      return
    end

    if Rating.exists?(post: post, user: user)
      Rails.logger.warn("[Rating::ProcessJob] Duplicate rating attempt. post_id=#{post.id}, user_id=#{user.id}")
    end

    rating = Rating.new(post: post, user: user, value: value)

    if rating.save
      Rails.logger.info("[Rating::ProcessJob] Rating salvo com sucesso: #{rating.inspect}")
    else
      Rails.logger.warn("[Rating::ProcessJob] Falha ao salvar Rating: #{rating.errors.full_messages}")
    end
  end
end
