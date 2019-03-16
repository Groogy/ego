class Heightmap
  include CrystalClear

  DEFAULT_HEIGHT = 0f32

  @heights : Array(Float32)
  @texture : Boleite::Texture?
  @need_update = true

  getter size

  def initialize(@size : Boleite::Vector2u)
    @heights = Array(Float32).new @size.x * @size.y, DEFAULT_HEIGHT
  end

  private def pos_to_index(pos)
    pos.x + pos.y * @size.x
  end

  requires inside? pos
  def get_height(pos)
    index = pos_to_index pos
    @heights[index]
  end

  requires inside? pos
  def set_height(pos, height)
    index = pos_to_index pos
    @heights[index] = height
    @need_update = true
  end

  def set_height(x, y, height)
    set_height Boleite::Vector2u.new(x.to_u, y.to_u), height
  end

  def [](pos)
    get_height pos
  end

  def []=(pos, height)
    set_height pos, height
  end

  def inside?(pos)
    pos.x >= 0 && pos.x < @size.x && pos.y >= 0 && pos.y < @size.y
  end

  def generate_texture(gfx) : Boleite::Texture
    unless @texture
      texture = gfx.create_texture
      texture.create @size.x, @size.y, Boleite::Texture::Format::Red, Boleite::Texture::Type::Float32
      texture.smooth = false
      texture.repeating = false
      @texture = texture
    end

    if (texture = @texture)
      if @need_update
        bytes = @heights.to_unsafe
        texture.update bytes, @size.x, @size.y, 0, 0, Boleite::Texture::Format::Red
        @need_update = false
      end
      return texture
    end
    raise "Failed to create texture for terrain map"
  end
end
