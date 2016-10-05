# The backend uses services to manage CRUD operations
# for domain objects

class BookingService

  # Check if a particular room is booked for a given date and time slot
  def BookingService.free?(room, date, from, to)
    room_id = room.id
    params = {}
    params[:from] = from
    params[:to] = to
    params[:room_id] = room_id
    params[:date] = date
    # The room is free if there is no overlapping booking.
    # Overlap exists if the start and end time's overlap with the
    # the time interval of interest - parameters to this method

    booking = Booking.where('((start_time = ? AND end_time = ?)
                               OR (start_time >= ? AND start_time < ?)
                               OR (? >= start_time AND ? < end_time) )
                             AND (room_id = ? AND day = ?)', params[:from], params[:to],
                            params[:from], params[:to],
                            params[:from], params[:from],
                            params[:room_id], params[:date])
    return booking.length == 0
  end

  # Check if a booking exists for a user given a date and start time
  def BookingService.booking_exists?(user, date, start)
    booking = Booking.find_by user_id: user.id, day: date, start_time: start
    booking != nil
  end

  # Create a new booking!
  # A booking can be created for a room and date and time slot ONLY
  # 1. if the room is free
  # 2. if the user does not have a parallel booking - another booking for the same time slot
  # 3. if create_booking is called with multiple flag true - for admin, then condition 2 is relaxed
  #    Condition 3, implements the extra credit requirement

  def BookingService.create_booking(room, date, from, to, for_user, attendees=nil, multiple=false)

    if BookingService.free?(room, date, from, to)
      if !BookingService.booking_exists?(for_user, date, from ) || multiple
        booking = Booking.new
        booking.day = date
        booking.start_time = from
        booking.end_time = to
        booking.attendees = attendees
        booking.user = for_user
        booking.room = room
        booking.save
        return booking
      end
    end
    return nil
  end

  # Return all bookings - past and current -  for a room
  def BookingService.all_bookings_for_room(room)
   b =  Booking.where('room_id = ?', room.id)
   b.sort_by {|i| [i.day, i.start_time]}
  end


  # Return all bookings - past and current - for a user
  def BookingService.all_bookings_for_user(user)
    b = Booking.where('user_id = ?', user.id)
    b.sort_by {|i| [i.day, i.start_time]}
  end

  # Return all bookings - past and current - in the system
  def BookingService.all_bookings
    b = Booking.all
    b.sort_by {|i| [i.day, i.start_time]}
  end

  # Delete a booking given a booking id
  def BookingService.delete_booking(booking)
    Booking.destroy(booking.id) # Consider soft-delete
  end

  # Return current bookings for a user - bookings in the next 7 days (including today)
  def BookingService.current_bookings_for_user(user)
    b = Booking.where('user_id = ? AND day >= ? AND day <= ?', user.id, Time.new.to_date, Time.new.to_date+6)
    b.sort_by {|i| [i.day, i.start_time]}
  end

  # Return current bookings for a room - bookings in the next 7 days (including today)
  def BookingService.current_bookings_for_room(room)
    b = Booking.where('room_id = ? AND day >= ? AND day <= ?', room.id, Time.new.to_date, Time.new.to_date+6)
    b.sort_by {|i| [i.day, i.start_time]}
  end

end