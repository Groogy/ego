struct GameTime
  TICKS_PER_HOUR = 60
  TICKS_PER_DAY = 60 * 24
  MINUTES_PER_HOUR = 60
  HOURS_PER_DAY = 24
  DAYS_PER_MONTH = 30
  MONTHS_PER_YEAR = 12

  MONTH_NAMES = { # Todo make up names
    "January", "February", "March", "April",
    "May", "June", "July", "August",
    "September", "October", "November", "December"
  }
  
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

  def initialize(data : Hash(String, Int64))
    data.each do |key, value|
      case key
      when "years" then add_years value
      when "months" then add_months value
      when "days" then add_days value
      when "hours" then add_hours value
      when "ticks" then add_ticks value
      else
        raise ArgumentError.new("Invalid hash given to construct time")
      end
    end
  end

  def next_tick
    GameTime.new @ticks + 1
  end

  def add_years(val)
    add_months val * MONTHS_PER_YEAR
  end

  def add_months(val)
    add_days val * DAYS_PER_MONTH
  end

  def add_days(val)
    @ticks += val * TICKS_PER_DAY
  end

  def add_hours(val)
    @ticks += val * TICKS_PER_HOUR
  end

  def add_ticks(val)
    @ticks += val
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

  def to_month_in_year_named
    MONTH_NAMES[to_month_in_year]
  end

  def to_formated_string
    "#{to_day_in_month + 1} of #{to_month_in_year_named} #{to_years}"
  end

  def to_i
    @ticks
  end

  def ==(val : Int)
    @ticks == val
  end

  def >(val : Int)
    @ticks > val
  end

  def <(val : Int)
    @ticks < val
  end

  def >=(val : Int)
    @ticks >= val
  end

  def <=(val : Int)
    @ticks <= val
  end

  def >(val : GameTime)
    @ticks > val.to_i
  end

  def <(val : GameTime)
    @ticks < val.to_i
  end

  def >=(val : GameTime)
    @ticks >= val.to_i
  end

  def <=(val : GameTime)
    @ticks <= val.to_i
  end

  def +(val : Int)
    GameTime.new @ticks + val
  end

  def -(val : Int)
    GameTime.new @ticks - val
  end

  def /(val : Int)
    GameTime.new @ticks / val
  end

  def *(val : Int)
    GameTime.new @ticks * val
  end
end