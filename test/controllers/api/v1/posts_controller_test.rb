require "test_helper"
require "mocha/minitest"

class Api::V1::PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
  end

  test "should get index" do
    get api_v1_posts_path
    assert_response :success
    json = JSON.parse(response.body)
    assert_kind_of Array, json
  end

  test "should post be posted" do
    post_fixture = posts(:one)

    post api_v1_posts_path,
      params: { post: { user_id: post_fixture.user_id, title: post_fixture.title, body: post_fixture.body, ip: post_fixture.ip } },
      as: :json
    assert_response :created

    all_data = post_fixture.slice(:user_id, :title, :body, :ip).stringify_keys
    final_data = JSON.parse(response.body).slice(*all_data.keys)

    assert_equal all_data, final_data
  end

  test "should verify if the user_id is valid" do
    post api_v1_posts_path,
      params: { post: { user_id: @user.id, title: "Any", body: "Any2", ip: "127.0.0.1" } },
      as: :json
    assert_response :created
    json = JSON.parse(response.body)
    assert_equal @user.id, json["user_id"]
  end

  test "should create post with login instead of user_id" do
    login = "login_enviado@test.com"

    post api_v1_posts_path,
      params: { post: { login: login, title: "Titulo login enviado", body: "conteudo login enviado", ip: "127.0.0.1" } },
      as: :json

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal login, User.find(json["user_id"]).login
  end

  test "should create a post with title not null" do
    post api_v1_posts_path,
      params: { post: { user_id: @user.id, title: "", body: "Any2", ip: "127.0.0.1" } },
      as: :json
    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_includes json["errors"].join, "Title can't be blank"
  end

  test "should create a post with body not null" do
    post api_v1_posts_path,
      params: { post: { user_id: @user.id, title: "Any", body: "", ip: "127.0.0.1" } },
      as: :json
    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_includes json["errors"].join, "Body can't be blank"
  end

  test "should create a post with ip not null" do
    ActionDispatch::Request.any_instance.stubs(:remote_ip).returns(nil)

    post api_v1_posts_path,
      params: { post: { user_id: @user.id, title: "Any", body: "Any2" } },
      as: :json
    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_includes json["errors"].join, "Ip can't be blank"
  end
end
