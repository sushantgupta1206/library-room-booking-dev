class BookingService

  def BookingService.free?(room, date, from, to)
    room_id = room.id
    params = {}
    params[:from] = from
    params[:to] = to
    params[:room_id] = room_id
    params[:date] = date
    booking = Booking.where('((start_time = ? AND end_time = ?)
                               OR (start_time >= ? AND start_time < ?)
                               OR (? >= start_time AND ? < end_time) )
                             AND (room_id = ? AND day = ?)', params[:from], params[:to],
                            params[:from], params[:to],
                            params[:from], params[:from],
                            params[:room_id], params[:date])
    return booking.length == 0
  end

  def BookingService.booking_exists?(user, date, start)
    booking = Booking.find_by user_id: user.id, day: date, start_time: start
    booking != nil
  end

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

  def BookingService.all_bookings_for_room(room)
   b =  Booking.where('room_id = ?', room.id)
   b.sort_by {|i| [i.day, i.start_time]}
  end


  def BookingService.all_bookings_for_user(user)
    b = Booking.where('user_id = ?', user.id)
    b.sort_by {|i| [i.day, i.start_time]}
  end

  def BookingService.all_bookings
    b = Booking.all
    b.sort_by {|i| [i.day, i.start_time]}
  end

  def BookingService.delete_booking(booking)
    Booking.destroy(booking.id) # Consider soft-delete
  end

  def BookingService.current_bookings_for_user(user)
    b = Booking.where('user_id = ? AND day >= ? AND day <= ?', user.id, Time.new.to_date, Time.new.to_date+6)
    b.sort_by {|i| [i.day, i.start_time]}
  end

  def BookingService.current_bookings_for_room(room)
    b = Booking.where('room_id = ? AND day >= ? AND day <= ?', room.id, Time.new.to_date, Time.new.to_date+6)
    b.sort_by {|i| [i.day, i.start_time]}
  end

end