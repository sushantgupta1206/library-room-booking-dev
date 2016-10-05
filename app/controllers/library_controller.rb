require 'services/common.rb'

#
# LibraryController is the controller that manages login and
# redirects to the appropriate conroller depending on the type of
# user.
#
# LibraryController also supports action for new user signup - only library users.
# New admin users are created by preconfigured admin


class LibraryController < ApplicationController
  # A before action method check_login is a filter method that is used to
  # check a user who already has an active session is visiting the application
  # This can happen when the user enters the home page URL for the application from
  # another tab while an active session exists in a tab in the browser.

  before_action :check_login
  private

  def check_login
    if session[:user] != nil
      emailId = session[:user]
    # If the user with valid session is admin redirect to admin controller
      if UserService.is_admin(emailId)
        redirect_to :controller => 'admin', :action => 'home'
        return
      else
        # Else redirect to user controller for library users.
        redirect_to :controller => 'user', :action => 'home'
        return
      end

    end
  end

  public

  # No action needed here for home page. It is mostly rendering the login form with signup link
  # The view renders the form
  def index

  end

  # The signup view renders the signup form
  def signup

  end

  # The login action authenticates using the UserService. There are three cases
  # resulting from authentication.
  #  1. The user is not authenticated. Then we redirect to home page indicating failed login
  #  2. The user is authenticated and the user is an admin user. We redirect to admin home page
  #  3. The user is authenticated and the user is a library user. We redirect to (Library)user home page

  def login
    emailId = params[:id];
    password = params[:password]
    userauth = UserService.authenticate(emailId,password)
    flash.delete(:error)

    if !userauth
      flash[:error] = "Login failed!"
      render :index
      return
    end

      session[:user] = emailId
      if UserService.is_admin(emailId)
        redirect_to :controller => 'admin', :action => 'home'
        return
      else
        redirect_to :controller => 'user', :action => 'home'
        return
      end
  end

  # The new user action is called when a new user signs up
  # Password and confirm passowrd have to match.
  # If they do, then a new library user is created if there is
  # no other user with the same email id.
  # Appropriate errors are returned in flash hash.

  def new_user

    # get the form parameters
    emailId = params[:id]
    password = params[:password]
    cpassword = params[:cpassword]
    fname = params[:fname]
    lname = params[:lname]

    # Clear old errors, if any.

    flash.delete("error");

    if password != cpassword
      flash[:error] = 'Password and Confirm Password do not match!'
      redirect_to action: 'signup'
      return
    end

    if UserService.find_user(emailId) != nil
      flash[:error] = "User with #{emailId} already exists!"
      redirect_to action: 'signup'
      return
    end
    UserService.create_library_user(emailId,fname,lname,password,cpassword)
    redirect_to action: 'index'
    return
  end

end
