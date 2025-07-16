class Api::V1::RatingsController < ApplicationController
  def index
    ratings = Rating.all
    render json: ratings
  end

  def create
    post_id = rating_params[:post_id]
    user_id = rating_params[:user_id]
    value = rating_params[:value].to_i

    if post_id.blank? || user_id.blank? || value.blank?
      return render_error("Missing parameters: post_id, user_id, and value are required.")
    end

    if Rating.exists?(post_id: post_id, user_id: user_id)
      return render json: {
        error: "User has already rated this post."
      }, status: :unprocessable_entity
    end

    Rating::ProcessJob.perform_later(post_id.to_i, user_id.to_i, value.to_i)

    render json: { message: "Rating submitted successfully!", rating_average: Post.find(post_id).rating_average(value) }, status: :accepted

    private
    def rating_params
      params.require(:rating).permit(:post_id, :user_id, :value)
    end
  end
end
