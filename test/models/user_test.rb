require 'test_helper'
require 'services/common.rb'

class UserTest < ActiveSupport::TestCase

  setup do
    user = UserService.create_library_user("lib@lib.edu", "Library", "User", "lib01", "lib01")
  end
  test "creation of admin user" do
    admin = UserService.create_admin("admin@admin.edu", "Admin", "Admin", "admin01", "admin01")
    assert User.find_by(emailId: "admin@admin.edu").is_admin = true
  end

  test "creation of library user" do
    UserService.create_library_user("lib1@lib.edu", "Library", "User", "lib01", "lib01")
    assert User.find_by(emailId: "lib1@lib.edu").is_admin == false
  end

  test "create of duplicate user" do
    user1 = UserService.create_library_user("lib1@lib.edu", "Library", "User", "lib01", "lib01")
    user2 = UserService.create_library_user("lib1@lib.edu", "Library", "User", "lib01", "lib01")

    assert user1 != nil
    assert user2 == nil
  end

  test "user password encryption" do
    user2 = UserService.find_user "lib@lib.edu"
    assert user2.password != "lib01"
  end

  test "user password authentication " do
    assert UserService.authenticate("lib@lib.edu", "lib01") == true
  end

  test "user password authentication failure" do
    assert UserService.authenticate("lib@lib.edu", "lib02") == false
  end

  test "change password" do
    UserService.change_password("lib@lib.edu", "lib02", "lib02")
    assert UserService.authenticate("lib@lib.edu", "lib01") ==false
    assert UserService.authenticate("lib@lib.edu", "lib02") == true
  end

  test "change name" do
    user1 = UserService.find_user ("lib@lib.edu")
    assert user1.first_name = "Library"
    assert user1.last_name = "User"
    UserService.change_name(user1, "Lib", "Usr")
    assert user1.first_name = "Lib"
    assert user1.last_name = "Usr"
  end
end
