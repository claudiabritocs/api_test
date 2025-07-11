require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get all users" do
    get api_v1_users_path, as: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert_kind_of Array, json
  end
  test "should create user with valid login" do
    post api_v1_users_path, params: { user: { login: "britoteste@test.com" } }, as: :json
    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "britoteste@test.com", json["login"]
  end

  test "should not create user without login/empty" do
    post api_v1_users_path, params: { user: { login: "" } }, as: :json
    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_includes json["error"] || json["errors"].join, "Login is required"
  end

  test "should not create user with duplicate login" do
    existing_user = users(:two)
    post api_v1_users_path, params: { user: { login: existing_user.login } }, as: :json
    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_includes json["errors"].join, "has already been taken"
  end

  test "should not create user with special characters in login" do
    post api_v1_users_path, params: { user: { login: "|nvalid u$er!" } }, as: :json
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"].join, "only allows letters, numbers, underscores, dots and dashes"
  end
end
