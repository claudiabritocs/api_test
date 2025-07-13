class ApplicationController < ActionController::API
  include ResponseHelper

  rescue_from(ActionController::ParameterMissing) do |error|
    render_error(error.message, :bad_request)
  end

  rescue_from(ArgumentError) do |error|
    render_error(error.message, :unprocessable_entity)
  end
end
