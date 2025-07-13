class ApplicationController < ActionController::API
  include ResponseHelper

  rescue_from(ActionController::ParameterMissing) do |error|
    render_error(error.message, :bad_request)
  end
end
