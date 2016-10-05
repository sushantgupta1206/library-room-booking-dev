require 'services/common.rb'

# AdminController is the controller that implements admin functionality

class AdminController < ApplicationController
  before_action :check_login

  # The check_login before_action filter method checks for
  # valid sessions and URL tampering (URL rewrites by user in the browser's address bar)
  # Tampering is detected if referrer URL is nil
  # If there is no valid session, the user is redirected to login page.
  # If URL is tampered, the user is redirected to page with URL tampering warning

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


  # Action for url tampered warning
  public
  def url_tampered
    @userId = UserService.find_user session[:user]
  end

  # Set up objects needed to render view
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

  # Action for editing the profile of a library user.
  def edit_profile
    @userId = UserService.find_user session[:user]
    @admin = UserService.find_user(session[:user])
  end

  # Action for manage admins. The view shows a list of
  # admin users who can be managed - CRUD

  def manage_admins
    @userId = UserService.find_user session[:user]
    @admins = UserService.all_admin_users
    flash.delete("error")
  end

  # Action for create admin view. The view renders a
  # form to create admin users

  def create_admin
    @userId = UserService.find_user session[:user]
  end

  # The action for creating a new admin. Invoked when
  # the form in create_admin view is submitted.
  # Do the usual checks - passwd and confirm passwd
  # match. Unique ID

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

    # Check if a user with the emailId exists.
    if UserService.find_user(emailId) != nil
      flash[:error] = "User with #{emailId} already exists!"
      redirect_to action: "create_admin"
      return
    end

    # Create new admin and return control to manage admins

    UserService.create_admin(emailId,fname,lname,password,cpassword)
    redirect_to action: "manage_admins"
    return
  end

  # Delete an admin. No foreign key/relation checks needed
  def delete_admin
    @userId = UserService.find_user session[:user]
    id = params[:id]
    admin = User.find(id)
    UserService.delete_user admin
    redirect_to  action: "manage_admins"
  end

  # Action for editing an admin object.
  # View renders form with fields for editing admin profile

  def edit_admin
    @userId = UserService.find_user session[:user]
    id = params[:id]
    @admin = User.find id
  end

  # Save admin changes. Updates to both library and
  # admin users are identical. Hence reusing the same
  # method. The save_changes method is paramterized
  # for redirect.

  def save_admin_changes
      save_changes "manage_admins"
  end

  # Common method to update users - both admin and library
  #
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
      flash[:error] = "Password and Change Password do not match"
    end
    user.save
    # redirect to parameterized method name based on admin and library user changes
    redirect_to action: redirect_method

  end


  # Admin's self profile change method. Uses
  # common method
  def save_profile_changes
      save_changes "home"
  end

  # Logout method. Deletes session and redirects to login page
  def logout
    session.delete(:user)
    redirect_to controller: "library", action: "index"
  end


  # Action for manage_rooms CRUD. The view creates
  # a list of existing rooms in each building. Setup
  # objects to render view

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

  # Action for deleting room bookings
  # View must display existing (current) bookings
  def delete_room_bookings
    id = params[:id]
    user = Room.find(id)
    show_room_bookings
  end

  # Action for viewing current bookings in each room

  def show_room_bookings
    @userId = UserService.find_user session[:user]
    room_id = params[:id]
    @room = Room.find(room_id)
    @bookings = BookingService.current_bookings_for_room @room
    @util = Util.new
  end

  # Action for deleting a room booking
  # This is a common action used when viewing a room's booking
  # and also when deleting bookings for a room in the process
  # of deleting a room.
  # This action figures out the redirect based on referrer URL
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

  # Action for create room view. A list of buildings is
  # is sent to the view, as rooms are created in a building.
  def create_room
    @userId = UserService.find_user session[:user]
    building_id = params[:id]
    @building = Building.find building_id
    @room_types = RoomTypeService.find_all
    @util = Util.new
    flash.delete "error";
  end

  # Action called when the create_room form is submitted
  # Room number uniqueness is checked before creating a room
  # If room number conflicts an error is returned through the flash hash
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

  # Action for editing a room. The view renders a
  # form with room attributes that are editable

  def edit_room
    @userId = UserService.find_user session[:user]
    @room = Room.find(params[:id])
    @building = @room.building
    @room_types = RoomTypeService.find_all
    @util = Util.new
    flash.delete "error";
  end

  # Action called when edit_room form is submitted
  # Check if room name/number clashes with other existing rooms.

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


  # Action for delete room.
  # Ordinarily only rooms that have no current bookings
  # must be deleted.
  # If there are existing bookings, render a page
  # that allows user to delete all bookings before deleting the room.
  # The user can still back out of deleting the room, after viewing
  # the bookings.

  def delete_a_room
    room_id = params[:id]
    room = Room.find(room_id)
    bookings = BookingService.current_bookings_for_room(room)
    # If there are exisiting bookings redirect to page to delete
    # existing bookings.
    if bookings.length > 0
      redirect_to  action: "delete_room_bookings", :id => room_id
      return
    end
    # Now delete all past bookings so that the foreign/relationship
    # between bookings and room constraint does not block us from
    # deleting the room
    bookings = BookingService.all_bookings_for_room(room)
    bookings.each {|b| Booking.destroy(b.id)}
    Room.destroy(room_id)
    redirect_to action: "manage_rooms"
  end

  # Action to render view for manage library users
  def manage_users
    @userId = UserService.find_user session[:user]
    @users = UserService.all_library_users
    flash.delete("error")
  end

  # Action to save a new user
  # Ccheck for email Id uniqueness.
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

  # Action for edit user. View renders user profile fields
  def edit_user
    @userId = UserService.find_user session[:user]
    id = params[:id]
    @user = User.find id
  end


  # Action for saving user changes.
  # Uses a common method for saving user changes for both
  # admin and library users.
  def save_user_changes
    save_changes "manage_users"
  end

  # Action for deleting a library user.
  # Ordinarily a user can be deleted if (s)he has no
  # room bookings. If a user has bookings, the view
  # to delete existing bookings is rendered.
  def delete_user
    id = params[:id]
    user = User.find(id)
    bookings = BookingService.current_bookings_for_user(user)
    # If there are exisiting bookings, redirect to view to delete them
    # before deleting the room
    if bookings.length > 0
      redirect_to action: "delete_user_bookings", :id => id
      return
    end
    # Delete all past bookings of the user before deleting the user
    bookings = BookingService.all_bookings_for_user(user)
    bookings.each {|b| Booking.destroy(b.id)}
    UserService.delete_user user
    redirect_to  action: "manage_users"
  end

  # Action to render the view for deleting user bookings
  def delete_user_bookings
    id = params[:id]
    user = User.find(id)
    show_user_bookings
  end

  # Action for view to show all - past and current bookings
  # of a user.
  def show_user_bookings
    @userId = UserService.find_user session[:user]
    id = params[:id]
    @user = User.find(id)
    @bookings = BookingService.all_bookings_for_user(@user)
    @util = Util.new
  end

  # Action to delete a user booking. This could
  # be called from view of showing bookings or deleting bookings
  # Using the referrer, figure out the redirect
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

  # Action to delete booking. Called from manage_bookings view
  def delete_booking
    id = params[:id]
    booking = Booking.find(id)
     BookingService.delete_booking(booking) if booking != nil
     redirect_to  action: "manage_bookings"
  end

  # Action to create a booking for a user. Called from manage
  # bookings. The parameter has encoded in it the room and time
  # slot. The View captures the user id.
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

  # Action called when form for create_booking is submitted.
  # The admin add_booking implements the extra credit functionality
  # which allows admin to create bookings for a time slot even when
  # a user has an existing booking.
  # Also implements the second extra credit requirement, where user notification to
  # list of attendees.

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
      attendeeList = attendees.split(",")
      attendeeList.each {|a| LibraryMailer.send_email(a,@booking,User.find(userId)).deliver}
    end
    redirect_to  action: "manage_bookings"
  end

  # Action for manage bookings. The view shows all rooms
  # in all buildings to provide a complete picture of existing
  # bookings for the admin. The admin can just choose a time slot
  # to create a new booking or delete an existing one.

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
