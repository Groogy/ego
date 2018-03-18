class Profiler
  ONE_SECOND = Time::Span.new seconds:1, nanoseconds:0

  @clock = Boleite::Clock.new
  @elapsed_time = Time::Span.zero
  @ticks = 0
  @last_ticks = 0
  @milliseconds_per_tick = 0.0

  getter milliseconds_per_tick

  def tick
    @ticks += 1
    this_tick = @clock.restart
    @milliseconds_per_tick = this_tick.total_milliseconds
    @elapsed_time += this_tick
    if @elapsed_time >= ONE_SECOND
      @last_ticks = @ticks
      @elapsed_time -= ONE_SECOND
      @ticks = 0
    end
  end

  def num_ticks_per_second
    @last_ticks
  end
end