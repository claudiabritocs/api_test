module Api
  module V1
    class RatingsController < ApplicationController
      def index
        ratings = Rating.all
        render json: ratings
      end

      def create
        rating = Rating.new(rating_params)

        return render_validation_errors(rating) unless rating.save

        render json: rating, status: :created
      end

      private

      def rating_params
        params.require(:rating).permit(:post_id, :user_id, :value)
      end
    end
  end
end
