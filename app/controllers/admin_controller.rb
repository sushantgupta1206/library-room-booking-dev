require 'services/common.rb'

# AdminController is the controller that implements admin functionality

class AdminController < ApplicationController
  before_action :check_login


  private
  def check_login
    userId = UserService.find_user session[:user]
    referrer = request.env['HTTP_REFERER']
    if userId == nil
      redirect_to controller: "library", action: "index"
      return
    end
    redirect_loop = request.original_url.index("url_tampered")
    puts "redirect_loop = #{redirect_loop}"
    puts "referrer = #{referrer}"
    if referrer == nil || referrer == ""
      if redirect_loop == nil
          redirect_to action: "url_tampered"
          return
      end
      return
    end
  end



  public
  def url_tampered
    @userId = UserService.find_user session[:user]
  end

  def home
    @userId = UserService.find_user session[:user]
    @ListOfRooms = RoomService.find_all();
    @RoomTypes = RoomTypeService.find_all()
    @ListOfAdmins = UserService.all_admin_users()
    @ListOfLibraryUsers = UserService.all_library_users()
    @ListOfBuildings = BuildingService.find_all()
    @RoomList = []
    @ListOfBuildings.each {|b|
      rooms = RoomService.find_all_in_building(b)
      @RoomList << [b,rooms]
    }
 end

  def edit_profile
    @userId = UserService.find_user session[:user]
    @admin = UserService.find_user(session[:user])
  end

  def manage_admins
    @userId = UserService.find_user session[:user]
    @admins = UserService.all_admin_users
    flash.delete("error")
  end


  def create_admin
    @userId = UserService.find_user session[:user]
  end

  def new_admin
    @userId = UserService.find_user session[:user]
    emailId = params[:id]
    password = params[:password]
    cpassword = params[:cpassword]
    fname = params[:fname]
    lname = params[:lname]

    flash.delete("error");

    if password != cpassword
      flash[:error] = "Password and Confirm Password do not match"
      redirect_to action: "create_admin"
      return
    end

    if UserService.find_user(emailId) != nil
      flash[:error] = "User with #{emailId} already exists!"
      redirect_to action: "create_admin"
      return
    end
    UserService.create_admin(emailId,fname,lname,password,cpassword)
    redirect_to action: "manage_admins"
    return
  end

  def delete_admin
    @userId = UserService.find_user session[:user]
    id = params[:id]
    admin = User.find(id)
    UserService.delete_user admin
    redirect_to  action: "manage_admins"
  end

  def edit_admin
    @userId = UserService.find_user session[:user]
    id = params[:id]
    @admin = User.find id
  end

  def save_admin_changes
      save_changes "manage_admins"
  end

  def save_changes(redirect_method)
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
      flash[:error] = "Password and Confirm Password do not match"
    end
    user.save
    redirect_to action: redirect_method

  end


  def save_profile_changes

      save_changes "home"
  end

  def logout
    session.delete(:user)
    redirect_to controller: "library", action: "index"
  end
  def manage_rooms

    @userId = UserService.find_user session[:user]
    @ListOfRooms = RoomService.find_all();
    @RoomTypes = RoomTypeService.find_all()
    @ListOfBuildings = BuildingService.find_all()
    @RoomList = []
    @ListOfBuildings.each {|b|
      rooms = RoomService.find_all_in_building(b)
      @RoomList << [b,rooms]
    }
  end

  def delete_room_bookings
    id = params[:id]
    user = Room.find(id)
    show_room_bookings
  end

  def show_room_bookings
    @userId = UserService.find_user session[:user]
    room_id = params[:id]
    @room = Room.find(room_id)
    @bookings = BookingService.current_bookings_for_room @room
    @util = Util.new
  end

  def delete_a_room_booking
    booking_id = params[:id]
    booking = Booking.find(booking_id)
    room_id = booking.room.id
    BookingService.delete_booking booking
    referrer = request.env['HTTP_REFERER']
    index = referrer.index("delete_room_bookings")
    back_to = "show_room_bookings"
    back_to = "delete_room_bookings" if !index.nil?
    redirect_to action: back_to  ,:id => room_id
  end

  def create_room
    @userId = UserService.find_user session[:user]
    building_id = params[:id]
    @building = Building.find building_id
    @room_types = RoomTypeService.find_all
    @util = Util.new
    flash.delete "error";
  end

  def new_room
      room_type = params[:room_type]
      room_name = params[:room_name]
      building_id = params[:building_id]
      room_type = RoomType.find(room_type)
      building = Building.find(building_id)
      flash.delete "error";

      existing_room = RoomService.find (room_name)
      if existing_room != nil && existing_room.building.id.to_i ==  building_id.to_i
        flash[:error] = "Room with name #{room_name} in #{building.name} already exists!"
        redirect_to action: "manage_rooms"
        return
      end
      room = RoomService.create room_name, building, room_type
      room.save
      redirect_to action: "manage_rooms"
      return
  end

  def edit_room
    @userId = UserService.find_user session[:user]
    @room = Room.find(params[:id])
    @building = @room.building
    @room_types = RoomTypeService.find_all
    @util = Util.new
    flash.delete "error";
  end

  def save_room_changes
    room_type = params[:room_type]
    room_name = params[:room_name]
    building_id = params[:building_id]
    room_id = params[:room_id]
    building = Building.find(building_id)

    existing_room = RoomService.find(room_name)
    if (existing_room != nil && existing_room.building_id.to_i == building_id.to_i &&  existing_room.id != room_id)
      flash[:error] = "Room with name #{room_name} in #{building.name} already exists!"
      redirect_to action: "manage_rooms"
      return
    end
    room = Room.find(room_id)
    room.name = room_name
    room.room_type = RoomType.find(room_type)
    room.save
    redirect_to action: "manage_rooms"
  end


  def delete_a_room
    room_id = params[:id]
    room = Room.find(room_id)
    bookings = BookingService.current_bookings_for_room(room)
    if bookings.length > 0
      redirect_to  action: "delete_room_bookings", :id => room_id
      return
    end
    bookings = BookingService.all_bookings_for_room(room)
    bookings.each {|b| Booking.destroy(b.id)}
    Room.destroy(room_id)
    redirect_to action: "manage_rooms"
  end

  def manage_users
    @userId = UserService.find_user session[:user]
    @users = UserService.all_library_users
    flash.delete("error")
  end

  def new_user
    emailId = params[:id]
    password = params[:password]
    cpassword = params[:cpassword]
    fname = params[:fname]
    lname = params[:lname]

    flash.delete("error");

    if password != cpassword
      flash[:error] = "Password and Confirm Password do not match"
      redirect_to action: "create_user"
      return
    end

    if UserService.find_user(emailId) != nil
      flash[:error] = "User with #{emailId} already exists!"
      redirect_to action: "create_user"
      return
    end
    UserService.create_library_user(emailId,fname,lname,password,cpassword)
    redirect_to action: "manage_users"
    return
  end

  def edit_user
    @userId = UserService.find_user session[:user]
    id = params[:id]
    @user = User.find id
  end

  def save_user_changes
    save_changes "manage_users"
  end

  def delete_user
    id = params[:id]
    user = User.find(id)
    bookings = BookingService.current_bookings_for_user(user)
    if bookings.length > 0
      redirect_to action: "delete_user_bookings", :id => id
      return
    end
    bookings = BookingService.all_bookings_for_user(user)
    bookings.each {|b| Booking.destroy(b.id)}
    UserService.delete_user user
    redirect_to  action: "manage_users"
  end

  def delete_user_bookings
    id = params[:id]
    user = User.find(id)
    show_user_bookings
  end

  def show_user_bookings
    @userId = UserService.find_user session[:user]
    id = params[:id]
    @user = User.find(id)
    @bookings = BookingService.all_bookings_for_user(@user)
    @util = Util.new
  end

  def delete_a_user_booking
    id = params[:id]
    booking = Booking.find(id)
    user_id = booking.user.id
    BookingService.delete_booking(booking) if booking != nil
    referrer = request.env['HTTP_REFERER']
    index = referrer.index("delete_user_bookings")
    back_to = "show_user_bookings"
    back_to = "delete_user_bookings" if !index.nil?
    redirect_to action: back_to,  :id => user_id
  end


  def delete_booking
    id = params[:id]
    booking = Booking.find(id)
     BookingService.delete_booking(booking) if booking != nil
     redirect_to  action: "manage_bookings"
  end

  def create_booking
    @userId = UserService.find_user session[:user]
    time_slot = params[:id]
    booking_details = time_slot.split(":")
    @room = Room.find(booking_details[0])
    @day = booking_details[1]
    @from = booking_details[2]
    @users = UserService.all_library_users
    @util = Util.new

  end


  def add_booking
    @userId = UserService.find_user session[:user]
    userId = params[:user]
    attendees = params[:attendees]
    @room = Room.find(params[:room])
    @day = DateTime.parse(params[:day])
    @from = params[:from].to_i
    @to = @from + 2
    @booking = BookingService.create_booking(@room, @day, @from, @to, User.find(userId),attendees,true)
    if (attendees != "")
      puts "sent email to #{attendees}"
      LibraryMailer.send_email(attendees,@booking,User.find(userId)).deliver
    end
    redirect_to  action: "manage_bookings"
  end


  def manage_bookings
    @userId = UserService.find_user session[:user]
    @util = Util.new
    @RoomList = []
    @BookingList = {}
    @ListOfBuildings = BuildingService.find_all()
    @ListOfBuildings.each { |b|
      rooms = RoomService.find_all_in_building(b)
      @RoomList << [b, rooms]
    }
    @num_users = UserService.all_library_users.length
    # Create a booking list, which is a hash. The key has booking time and the value is booking
    @RoomList.each {|item|
      item[1].each {|room|
        bookings = BookingService.all_bookings_for_room(room)
        bookings.each {|booking|
        @BookingList["#{room.id}:#{booking.day}:#{booking.start_time}"] = booking
        }
      }
    }
  end

end
