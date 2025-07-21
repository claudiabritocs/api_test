class Api::V1::PostsController < ApplicationController
  def index
    posts = Post.all
    render json: posts
  end

  def create
    post = CreatePostWithUser.new(post_params, request.remote_ip).call

    return render_validation_errors(post) unless post.save

    render json: post, status: :created

  rescue ArgumentError => e
    render_error(e.message, :unprocessable_entity)
  end

  def batch_create
    posts_params = params.require(:posts)

    logins = posts_params.map { |p| p[:login] }.uniq

    users_map = User.where(login: logins).pluck(:login, :id).to_h

    missing_logins = logins - users_map.keys

    now = Time.current

    if missing_logins.any?
      new_users = missing_logins.map { |login| { login: login, created_at: now, updated_at: now } }
      User.insert_all(new_users)

      users_map = User.where(login: logins).pluck(:login, :id).to_h
    end

    sanitized_posts = posts_params.map do |post_param|
      post_data = post_param.permit(:title, :body, :ip).to_h
      login = post_param[:login]
      post_data[:user_id] = users_map[login]
      post_data[:created_at] = now
      post_data[:updated_at] = now
      post_data
    end

    Post.insert_all(sanitized_posts)
    created_ids = Post.order(created_at: :desc).limit(posts_params.size).pluck(:id)

    render json: { created: sanitized_posts.size, created_ids: created_ids }, status: :created
  end

  def best_posts
    posts = Post.best_rated(10)
    render json: posts.as_json(only: [ :id, :title, :body ])
  end

  private

  def post_params
    params.require(:post).permit(:user_id, :title, :body, :ip, :login)
  end
end
