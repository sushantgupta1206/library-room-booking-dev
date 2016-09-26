require 'test_helper'
require 'services/common.rb'

class LibraryControllerControllerTest < ActionDispatch::IntegrationTest

  setup do
    admin = UserService.create_admin("admin@admin.edu", "Admin", "Admin", "admin01", "admin01")
    user = UserService.create_library_user("lib@lib.edu", "Library", "User", "lib01", "lib01")
  end

  def test_index
    get "/"
    assert_equal 200, status
  end

  def test_admin_login
    get "/"
    post "/library/login", params: {id: "admin@admin.edu", password: "admin01"}
    follow_redirect!
    assert_equal 200, status
    assert_equal "/admin/home", path
  end

  def test_user_login
    get "/"
    post "/library/login", params: {id: "lib@lib.edu", password: "lib01"}
    follow_redirect!
    assert_equal 200, status
    assert_equal "/user/home", path
  end

  def test_failed_login
    get "/"
    post "/library/login", params: {id: "lib@lib.edu", password: "lib02"}
    assert_equal 200, status
    assert_equal 'Login failed! Please check your email ID and password.',flash[:error]
  end

  def test_sign_up
    get "/signup"

    post "/library/new_user", params: {id: "lib2@lib.edu", password:"lib02", cpassword:"lib02", fname:"First", lname: "Last"}
    assert_equal 302, status
    user = User.find_by(emailId: "lib2@lib.edu")
    assert_equal user.is_admin, false
  end

  def test_failed_signup
    get "/signup"

    post "/library/new_user", params: {id: "lib2@lib.edu", password:"lib02", cpassword:"lib0", fname:"First", lname: "Last"}
    assert_equal "Passwords do not match!", flash[:error]

  end
end
