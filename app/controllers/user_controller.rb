require 'services/common.rb'

class UserController < ApplicationController
  before_action :check_login

  private
    def check_login
      userId = UserService.find_user session[:user]
      if userId == nil
        redirect_to controller: "library", action: "index"
      end
    end

  public
  def home
    @userId = UserService.find_user session[:user]
    @buildingsList = Building.all
    @roomTypes = Room.all

  end

  def edit_profile
    @userId = UserService.find_user session[:user]

  end

  def save_profile_changes
    first_name = params[:first_name]
    last_name = params[:last_name]
    emailId = params[:id]
    user = UserService.find_user(emailId);
    UserService.change_name(emailId, first_name, last_name);
    pw = params[:password]
    cpw = params[:cpassword]

    if (pw == cpw)
      UserService.change_password(emailId,pw,cpw)
    else
      flash[:error] = "Passwords do not match"
    end
    user.save
    redirect_to action: "home"

  end
  def search
    @userId = UserService.find_user session[:user]
    @buildingList = Building.all
    @roomTypes = RoomType.all
    @search_string = session[:search_string] || "Enter Room Number"
    session.delete(:search_string)
    @search_results = session[:search_results]
    session.delete(:search_results)
  end


  def search_results

    room_number = params[:room_number]
    building_id = params[:building]
    room_type_id = params[:room_type]

    room = RoomService.search_room(room_number,building_id, room_type_id)
    building = Building.find(building_id).name
    session[:search_results] = [building, room]
    room_type = RoomType.find(room_type_id)
    if (room.length == 0)
      flash[:error] = "No rooms available with search criteria in " + building + " of size " + room_type.size
    end
    redirect_to action: "search"
  end


  def manage_bookings
    @userId = UserService.find_user session[:user]
    @bookings = BookingService.all_bookings_for_user(@userId)
    @util = Util.new
  end

  def create_booking
    @userId = UserService.find_user session[:user]
    @BookingList = {}
    @room = Room.find(params[:id])
    bookings = BookingService.current_bookings_for_room(@room)
    bookings.each {|booking|
      @BookingList["#{@room.name}:#{booking.day}:#{booking.start_time}"] = booking
    }
    @util = Util.new
  end

  def new_booking
    @userId = UserService.find_user session[:user]
    time_slot = params[:id]
    booking_details = time_slot.split(":")
    @room = RoomService.find(booking_details[0])
    @day = booking_details[1]
    @from = booking_details[2]
    @util = Util.new

  end

  def delete_booking
    id = params[:id]
    booking = Booking.find(id)
    room_id = booking.room.id
    BookingService.delete_booking(booking) if booking != nil
    redirect_to action: "create_booking" ,:id => room_id
  end

  def delete_user_booking
    id = params[:id]
    booking = Booking.find(id)
    room_id = booking.room.id
    BookingService.delete_booking(booking) if booking != nil
    redirect_to action: "manage_bookings" ,:id => room_id
  end

  def add_booking
    @userId = UserService.find_user session[:user]
        attendees = params[:attendees]
    @room = Room.find(params[:room])
    @day = DateTime.parse(params[:day])
    @from = params[:from].to_i
    @to = @from + 2
    @booking = BookingService.create_booking(@room, @day, @from, @to, @userId,attendees)
    if (attendees != "")
      puts "sent email to #{attendees}"
      LibraryMailer.send_email(attendees,@booking).deliver
    end
    redirect_to  action: "create_booking" ,:id => params[:room]
  end
end
