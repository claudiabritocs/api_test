class ApplicationController < ActionController::API
  include ResponseHelper

  rescue_from(ActionController::ParameterMissing) do |e|
    render_error(e.message, :bad_request)
  end
end
