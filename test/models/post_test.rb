require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "should have a valid user_id" do
    post = Post.new(user_id: users(:one).id)
    assert User.exists?(post.user_id)
  end

  test "should not be valid without a title" do
    post = Post.new(title: nil, body: "Conteudo teste", ip: "127.0.0.1", login: "teste@test.com")
    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
  end

  test "should not be valid without a body" do
    post = Post.new(title: "Titulo teste", body: nil, ip: "127.0.0.1", login: "teste@test.com")
    assert_not post.valid?
    assert_includes post.errors[:body], "can't be blank"
  end

  test "should not be valid without an ip" do
    post = Post.new(title: "Titulo teste", body: "Conteudo teste", ip: nil, login: "teste@test.com")
    assert_not post.valid?
    assert_includes post.errors[:ip], "can't be blank"
  end

  test "should create a new user if user_id doesn't exist" do
    login = "teste-deve-criar@test.com"
    assert_nil User.find_by(login: login)

    post = Post.new(login: login, title: "Titulo teste", body: "Texto teste", ip: "127.0.0.1")

    assert_difference("User.count", 1) do
      post.save
    end

    assert post.persisted?
    assert_not_nil post.user
    assert_equal login, post.user.login
  end
end
