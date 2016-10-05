require 'services/common.rb'
class LibraryMailer < ActionMailer::Base

  default from: "admin@ncsu.edu"

  def send_email(attendees, booking,user)
      attendeeList = attendees.split(",")
      util = Util.new
      @day = booking.day
      @time = util.friendly_hour(booking.start_time)
      @place = booking.room.name
      @who = user.first_name + " " + user.last_name
      attendeeList.each {|a|
        @user = Usr.new
        @user.email = a
        puts "sending email to #{a}"
        mail(to: @user.email, subject: 'Meeting')

      }
  end

end

class Usr
    attr_accessor :email
end