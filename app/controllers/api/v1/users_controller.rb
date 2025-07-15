module Api
  module V1
    class UsersController < ApplicationController
      def index
        users = User.all
        render json: users
      end

      def create
        login = user_params[:login]
        return render_error("Login is required, can't be blank.", :unprocessable_entity) if login.blank?

        user = User.new(login: login)
        return render_validation_errors(user) unless user.save

        render json: user, status: :created
      end

      def get_by_ip
        ips = User.ips_and_users
        render json: ips.map { |record| { ip: record.ip, logins: record.logins } }
      end

      private

      def user_params
        params.require(:user).permit(:login)
      end
    end
  end
end
