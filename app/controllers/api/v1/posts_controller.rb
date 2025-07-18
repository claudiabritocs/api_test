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

  def best_posts
    posts = Post.best_rated(10)
    render json: posts.as_json(only: [ :id, :title, :body ])
  end

  private

  def post_params
    params.require(:post).permit(:user_id, :title, :body, :ip, :login)
  end
end
