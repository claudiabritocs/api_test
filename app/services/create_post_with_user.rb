class CreatePostWithUser
    def initialize(params, ip)
        @params = params
        @ip = ip
        @login = @params[:login]
        @user_id = @params[:user_id]
    end

    def call
        fetch_user
        Post.new(handle_post_params)
    end

    private

    attr_accessor :user
    attr_reader :params, :user_id, :login, :ip

    def fetch_user
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
    end

    def handle_post_params
        filtered_params = @params.except(:login, :user_id)
        filtered_params.merge(user: user, ip: ip)
    end
end
