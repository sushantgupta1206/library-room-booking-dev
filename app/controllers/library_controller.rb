require 'services/common.rb'

class LibraryController < ApplicationController
  def index
   flash.delete("error")
  end

  def signup

  end

  def login
    emailId = params[:id];
    password = params[:password]
    userauth = UserService.authenticate(emailId,password)
    flash.delete(:error)

    if !userauth
      flash[:error] = "Login failed! Please check your email ID and password."
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

  def new_user
    emailId = params[:id]
    password = params[:password]
    cpassword = params[:cpassword]
    fname = params[:fname]
    lname = params[:lname]

    flash.delete("error");

    if password != cpassword
      flash[:error] = 'Passwords do not match!'
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
