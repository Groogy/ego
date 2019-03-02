class TectonicLine
  @points = [] of Boleite::Vector2i

  getter points

  def generate_shape(random, size)
    distance_left = random.get_zero_to_one * (size.x + size.y) / 4
    x, y = random.get_int(0, size.x), random.get_int(0, size.y)
    point = Boleite::Vector2i.new x.to_i, y.to_i
    angle = Math::PI * random.get_zero_to_one
    @points = [point]
    while distance_left > 0.0
      distance = random.get_zero_to_one * 10.0
      distance_left -= distance
      angle += Math::PI / 4.0 * (random.get_zero_to_one - 0.5)
      direction = Boleite::Vector2f.new Math.cos(angle), Math.sin(angle)
      point = point + (direction * distance).to_i
      @points << point
    end
  end
end

class TectonicsEngine
  @lines = [] of TectonicLine

  def each_line
    @lines.each do |l|
      yield l
    end
  end

  def generate_line(world)
    line = TectonicLine.new
    line.generate_shape world.random, world.map.size
    @lines << line
  end
end