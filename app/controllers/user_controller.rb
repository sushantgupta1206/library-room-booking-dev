require 'services/common.rb'

# UserController is the controller that contains all actions
# related to library user functionality

class UserController < ApplicationController
  before_action :check_login

  private

  # The check_login before_action filter method checks for
  # valid sessions and URL tampering (URL rewrites by user in the browser's address bar)
  # If there is no valid session, the user is redirected to login page.
  # If URL is tampered, the user is redirected to page with URL tampering warning

    def check_login
      referrer = request.env['HTTP_REFERER']
      userId = UserService.find_user session[:user]
      # If there is no session and a URL has been hijacked, redirect to login page
      if userId == nil
        redirect_to controller: "library", action: "index"
      end
      # Since the filter method is called for url_tampered redirect
      # we need to break a potential infinite loop of redirects
      # Check if the referer URL is url_tampered, then we break the loop
      redirect_loop = request.original_url.index("url_tampered")
      if referrer == nil || referrer == ""
        if redirect_loop == nil
          redirect_to action: "url_tampered"
          return
        end
        return
      end
    end

  public

  # Set up objects needed to render view
  def home
    @userId = UserService.find_user session[:user]
    @buildingsList = Building.all
    @roomTypes = Room.all

  end

  # Action for url tampered warning
  def url_tampered
    @userId = UserService.find_user session[:user]
  end

  # View renders form to edit profile details of user
  def edit_profile
    @userId = UserService.find_user session[:user]

  end


  # Save profile changes. Check for password and change password
  # match. Then update the object.

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
      flash[:error] = "Password and Change Password do not match"
    end
    user.save
    redirect_to action: "home"

  end

  # Search action is used to render view for both the ab initio search
  # screen and also the screen with search results.
  def search
    @userId = UserService.find_user session[:user]
    @buildingList = Building.all
    @roomTypes = RoomType.all
    @search_string = session[:search_string] || "Enter Room Number"
    session.delete(:search_string)
    @search_results = session[:search_results]
    session.delete(:search_results)
  end


  # The action for search results. However, the action redirects
  # to use the view for search.

  def search_results

    # Get form params and perform the search
    room_number = params[:room_number]
    building_id = params[:building]
    room_type_id = params[:room_type]

    room = RoomService.search_room(room_number,building_id, room_type_id)
    building = Building.find(building_id).name
    session[:search_results] = [building, room]
    room_type = RoomType.find(room_type_id)
    if (room.length == 0)
      flash[:error] = "No rooms available with search criteria: room_number = '" +
          room_number + "' in " + building + " of size " + room_type.size
    end
    redirect_to action: "search"
  end


  # The view shows all bookings for the user. The user can view and delete
  # bookings.
  def manage_bookings
    @userId = UserService.find_user session[:user]
    @bookings = BookingService.all_bookings_for_user(@userId)
    @util = Util.new
  end

  # The action creates a list of existing bookigns so that the
  # User can see free and booked slots for each room.
  def create_booking
    @userId = UserService.find_user session[:user]
    @BookingList = {}
    @room = Room.find(params[:id])
    bookings = BookingService.current_bookings_for_room(@room)
    bookings.each {|booking|
      @BookingList["#{@room.id}:#{booking.day}:#{booking.start_time}"] = booking
    }
    @util = Util.new
  end

  # The view for this action has the form to create a new booking
  # It also takes the list of attendees to whom notification email
  # of the booking can be sent - implements extra credit requirement

  def new_booking
    @userId = UserService.find_user session[:user]
    time_slot = params[:id]
    booking_details = time_slot.split(":")
    @room = Room.find(booking_details[0])
    @day = booking_details[1]
    @from = booking_details[2]
    @util = Util.new

  end

  # Action to delete a booking when called from create_booking view
  # A booking with specified booking id is deleted and the existing booking
  # view is rendered
  def delete_booking
    id = params[:id]
    booking = Booking.find(id)
    room_id = booking.room.id
    BookingService.delete_booking(booking) if booking != nil
    redirect_to action: "create_booking" ,:id => room_id
  end

  # This action is called from manage booking when when a user
  # clicks on the x mark. THis deletes the booking. We check
  # for concurrent deletes just to make sure the user has not
  # simultaneously invoked delete on the same booking!

  def delete_user_booking
    id = params[:id]
    booking = Booking.find(id)
    room_id = booking.room.id
    BookingService.delete_booking(booking) if booking != nil
    redirect_to action: "manage_bookings" ,:id => room_id
  end


  # This action is called when the form for new booking is submitted.

  def add_booking
    @userId = UserService.find_user session[:user]
    # Gather all form parameters
    attendees = params[:attendees]
    @room = Room.find(params[:room])
    @day = DateTime.parse(params[:day])
    @from = params[:from].to_i
    @to = @from + 2
    @booking = BookingService.create_booking(@room, @day, @from, @to, @userId,attendees)

    # Implement extra credit. If the there is a list of attendee email addresses, then
    # notify each user using the action mailer controller.
    if (attendees != "")
      puts "sent email to #{attendees}"
      LibraryMailer.send_email(attendees,@booking,@userId).deliver
    end
    redirect_to  action: "create_booking" ,:id => params[:room]
  end
end
