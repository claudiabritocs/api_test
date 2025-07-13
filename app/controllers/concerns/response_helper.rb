module ResponseHelper
  def render_error(message, status = :unprocessable_entity)
    puts "[DEBUG] Using ResponseHelper#render_error with: #{message.inspect}, #{status.inspect}"
    render json: { error: message }, status: status
  end

  def render_validation_errors(record)
    render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
  end
end
