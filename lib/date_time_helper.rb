
class DateTimeHelper

  def self.one_week_ago
    DateTime.current.in_time_zone.weeks_ago(1)
  end

end