require 'services/user_service.rb'
require 'services/room_type_service.rb'
require 'services/building_service.rb'
require 'services/room_service.rb'
require 'services/booking_service.rb'


class Util

  def past?(day,hour)
      now = Time.now
      date = Time.local(day.year, day.mon,day.mday,hour)

      date < now
  end

  def friendly_hour(t)
    case t.to_i
      when 0..11
        t.to_s+"am"
      when 12
        t.to_s+"noon"
      else
        (t.to_i-12).to_s+"pm"
    end
  end
end
