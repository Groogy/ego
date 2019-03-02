class Heightmap
  DEFAULT_HEIGHT = 0f32

  @heights : Array(Float32)
  @texture : Boleite::Texture?
  @extremes = {DEFAULT_HEIGHT, DEFAULT_HEIGHT}
  @need_update = true

  def initialize(@size : Boleite::Vector2u)
    @heights = Array(Float32).new @size.x * @size.y, DEFAULT_HEIGHT
  end

  def calculate_extremes
    low = Float32::MAX
    high = Float32::MIN
    @heights.each do |h|
      low = {low, h}.min
      high = {high, h}.max
    end
    return low, high
  end

  def extremes : Tuple(Float32, Float32)
    @extremes
  end

  macro pos_to_index(pos)
    pos.x + pos.y * @size.x
  end

  def [](pos)
    index = pos_to_index pos
    @heights[index]
  end

  def []=(pos, height)
    index = pos_to_index pos
    if height > @extremes[1]
      @extremes[1] = height
    elsif height < extremes[0]
      @extremes[0] = height
    end
    @heights[index] = height
    @need_update = true
  end

  def generate_texture(gfx) : Boleite::Texture
    unless @texture
      texture = gfx.create_texture
      texture.create @size.x, @size.y, Boleite::Texture::Format::Red, Boleite::Texture::Type::Float32
      @texture = texture
    end

    if (texture = @texture)
      if @need_update
        bytes = @heights.to_unsafe
        texture.update bytes, @size.x, @size.y, 0, 0, Boleite::Texture::Format::Red
        @extremes = calculate_extremes
        @need_update = false
      end
      return texture
    end
    raise "Failed to create texture for terrain map"
  end
end