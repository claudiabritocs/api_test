require "test_helper"

class Api::V1::RatingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    ActiveJob::Base.queue_adapter = :test
  end

  test "should return error if params are missing" do
    post api_v1_ratings_url, params: { rating: { post_id: nil, user_id: nil, value: nil } }

    assert_response :unprocessable_entity
    assert_includes @response.parsed_body["error"].downcase, "missing parameters"
  end

  test "should enqueue Rating::ProcessJob with valid params" do
    ActiveJob::Base.queue_adapter = :test

    assert_enqueued_with(job: Rating::ProcessJob, args: [ posts(:one).id.to_s, users(:default_user).id.to_s, 4 ]) do
      post api_v1_ratings_url, params: {
        rating: {
          post_id: posts(:one).id,
          user_id: users(:default_user).id,
          value: 4
        }
      }
    end

    assert_response :accepted
  end
end
