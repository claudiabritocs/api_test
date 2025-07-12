class Api::V1::PostsController < ApplicationController
  def index
    posts = Post.all
    render json: posts
  end

  def create
    post = Post.new(post_params)

    return render_validation_errors(post) unless post.save

    render json: post, status: :created
  end

  private

  def post_params
    params.require(:post).permit(:user_id, :title, :body, :ip)
  end
end
