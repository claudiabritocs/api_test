class CreatePostWithUser
    def initialize(params, ip)
        @params = params
        @ip = ip
    end

    def call
        login = @params[:login]
        user_id = @params[:user_id]

        if login.present?
            user = User.find_or_create_by(login: login)
            if user_id.present? && user.id != user_id.to_i
                raise ArgumentError, "user_id does not match the login provided"
            end
        elsif user_id.present?
            user = User.find(user_id)
        else
            raise ArgumentError, "Login or user_id required"
        end

        filtered_params = @params.except(:login, :user_id)
        Post.new(filtered_params.merge(user: user, ip: @ip))
    end
end
