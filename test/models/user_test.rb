require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "login is required" do
    user = User.new(login: nil)
    assert_not user.valid?
  end

  test "login cannot be empty" do
    user = User.new(login: "")
    assert_not user.valid?
    assert_includes user.errors[:login], "can't be blank"
  end

  test "find_or_create_by create the user if doesnt exist" do
    login = "new@test.com"

    User.where(login: login).delete_all

    user = User.find_or_create_by(login: login)
    assert user.persisted?
    assert_equal login, user.login
  end

  test "find_or_create_by return existent user" do
    existing_user = users(:one)

    user = User.find_or_create_by(login: existing_user.login)
    assert_equal existing_user.id, user.id
  end

  test "login has to be unique" do
    user1 = users(:one)
    user2 = User.new(login: user1.login)
    assert_not user2.valid?
    assert_includes user2.errors[:login], "has already been taken"
  end

 test "login can't have special characters" do
    invalid_logins = [ "Grif!noria", "$onserina", "Lufa lufa" ]

    invalid_logins.each do |login|
      user = User.new(login: login)
      assert_not user.valid?, "#{login.inspect} should be invalid"
      assert_includes user.errors[:login], "only allows letters, numbers, underscores, dots and dashes"
    end
  end
end
