require 'services/common.rb'
class LibraryMailer < ActionMailer::Base

  default from: "admin@ncsu.edu"

  # A standard action to send email. The
  # attendees list is a comma-separated list of
  # email ids. We loop through  the attendee list
  # and send mail using the action mailer gem

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