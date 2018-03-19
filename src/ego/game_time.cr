struct GameTime
  TICKS_PER_HOUR = 60
  TICKS_PER_DAY = 60 * 24
  MINUTES_PER_HOUR = 60
  HOURS_PER_DAY = 24
  DAYS_PER_MONTH = 30
  MONTHS_PER_YEAR = 12
  
  @ticks = 0i64

  def self.convert_ticks_to_minutes(ticks)
    ticks
  end

  def self.convert_ticks_to_hours(ticks)
    convert_ticks_to_minutes(ticks) / MINUTES_PER_HOUR
  end

  def self.convert_ticks_to_days(ticks)
    convert_ticks_to_hours(ticks) / HOURS_PER_DAY
  end

  def self.convert_ticks_to_months(ticks)
    convert_ticks_to_days(ticks) / DAYS_PER_MONTH
  end

  def self.convert_ticks_to_years(ticks)
    convert_ticks_to_months(ticks) / MONTHS_PER_YEAR
  end

  def initialize
  end

  def initialize(@ticks)
  end

  def next_tick
    GameTime.new @ticks + 1
  end

  def to_years
    GameTime.convert_ticks_to_years @ticks
  end
  
  def to_months
    GameTime.convert_ticks_to_months @ticks
  end

  def to_days
    GameTime.convert_ticks_to_days @ticks
  end

  def to_hours
    GameTime.convert_ticks_to_hours @ticks
  end

  def to_minutes
    convert_ticks_to_minutes @ticks
  end

  def to_month_in_year
    to_months % MONTHS_PER_YEAR
  end

  def to_day_in_month
    to_days % DAYS_PER_MONTH
  end

  def to_hour_in_day
    to_hours % HOURS_PER_DAY
  end

  def to_formated_string
    "Year #{to_years} Month #{to_month_in_year} Day #{to_day_in_month} Hour #{to_hour_in_day}"
  end

  def to_i
    @ticks
  end
end