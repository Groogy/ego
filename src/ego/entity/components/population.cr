class PopulationComponent < EntityComponent
  include CrystalClear
  
  @population : Int64
  @growth = GameTime.new

  def initialize(data, entity, world)
    super data, entity, world
    @population = data.get_int "start"
  end

  def current_population
    @population
  end

  def current_growth
    @growth
  end

  def max_population
    @data.get_int "max"
  end

  def base_growth
    @data.get_gametime "growth"
  end

  def time_for_next_growth
    self.base_growth / @population
  end

  def advance_growth
    @growth = @growth.next_tick
    if @growth >= time_for_next_growth
      @population += 1i64 if @population < max_population
      @growth = GameTime.new
    end
  end

  invariant self.current_population > 0
  invariant self.current_population <= self.max_population
  invariant self.current_growth >= 0
end
