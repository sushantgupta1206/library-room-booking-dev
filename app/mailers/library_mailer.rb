class LibraryMailer < ActionMailer::Base

  default from: "admin@ncsu.edu"

  def send_email(attendees, booking)
      attendeeList = attendees.split(",")
      @booking = booking
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