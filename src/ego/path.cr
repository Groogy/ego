class Path
  @points = [] of Map::Pos
  @step = 1

  getter step
  delegate empty?, size, to: @points

  def add(pos)
    @points << Map::Pos.new pos
  end

  def next_tile
    @points[@points.size - @step - 1]
  end

  def last_tile
    @points.first
  end

  def progress
    @step = {@step + 1, @points.size - 1}.min
  end

  def end?
    @step >= @points.size - 1
  end
end