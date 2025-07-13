module Api
  module V1
    class RatingsController < ApplicationController
      def index
        ratings = Rating.all
        render json: ratings
      end

      def create
        post_id = rating_params[:post_id]
        user_id = rating_params[:user_id]
        value = rating_params[:value]

        Rating::ProcessJob.perform_later(post_id, user_id, value)

        render json: { message: 'Rating is being processed' }, status: :accepted
      end

      private

      def rating_params
        params.require(:rating).permit(:post_id, :user_id, :value)
      end
    end
  end
end
