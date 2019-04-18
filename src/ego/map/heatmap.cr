class Heatmap
  include CrystalClear

  DEFAULT_HEAT = 0.1f32

  @heat : Array(Float32)
  @texture : Boleite::Texture?
  @need_update = true

  getter size

  def initialize(@size : Boleite::Vector2u)
    @heat = Array(Float32).new @size.x * @size.y, DEFAULT_HEAT
  end

  private def pos_to_index(pos)
    pos.x + pos.y * @size.x
  end

  requires inside? pos
  def get_heat(pos)
    index = pos_to_index pos
    @heat[index]
  end

  requires inside? index
  def get_heat(index : Int32)
    @heat[index]
  end

  requires inside? pos
  def set_heat(pos, heat)
    index = pos_to_index pos
    @heat[index] = heat
    @need_update = true
  end

  def set_heat(x, y, heat)
    set_heat Boleite::Vector2u.new(x.to_u, y.to_u), heat
  end

  requires inside? index
  def set_heat(index : Int32, heat)
    @heat[index] = heat
    @need_update = true
  end

  def [](pos)
    get_heat pos
  end

  def []=(pos, heat)
    set_heat pos, heat
  end

  def inside?(index : Int32)
    index >= 0 && index < @heat.size
  end

  def inside?(pos)
    pos.x >= 0 && pos.x < @size.x && pos.y >= 0 && pos.y < @size.y
  end

  def each
    @heat.each { |v| yield v }
  end

  def each_with_index
    @heat.each_with_index { |v,i| yield v, i }
  end

  def each_with_pos
    pos = Boleite::Vector2u.zero
    each_with_index do |v, i|
      pos.x = (i % @size.x).to_u
      pos.y = (i / @size.x).to_u
      yield v, pos
    end
  end

  def map!
    @heat.map! { |v| yield v }
    @need_update = true
  end

  def map_with_index!
    @heat.map_with_index! { |v,i| yield v, i }
    @need_update = true
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
        bytes = @heat.to_unsafe
        texture.update bytes, @size.x, @size.y, 0, 0, Boleite::Texture::Format::Red
        @need_update = false
      end
      return texture
    end
    raise "Failed to create texture for heat map"
  end
end
