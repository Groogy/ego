class ValueMap
  include CrystalClear

  @values : Array(Float32)
  @texture : Boleite::Texture?
  @need_update = true

  getter size

  def initialize(default : Float32, @size : Boleite::Vector2u)
    @values = Array(Float32).new @size.x * @size.y, default
  end

  private def pos_to_index(pos)
    pos.x + pos.y * @size.x
  end

  requires inside? pos
  def get_value(pos)
    index = pos_to_index pos
    @values[index]
  end

  requires inside? index
  def get_value(index : Int32)
    @values[index]
  end

  requires inside? pos
  def set_value(pos, value)
    index = pos_to_index pos
    @values[index] = value
    @need_update = true
  end

  def set_value(x, y, value)
    set_value Boleite::Vector2u.new(x.to_u, y.to_u), value
  end

  requires inside? index
  def set_value(index : Int32, value)
    @values[index] = value
    @need_update = true
  end

  def [](pos)
    get_value pos
  end

  def []=(pos, value)
    set_value pos, value
  end

  def inside?(index : Int32)
    index >= 0 && index < @values.size
  end

  def inside?(pos)
    pos.x >= 0 && pos.x < @size.x && pos.y >= 0 && pos.y < @size.y
  end

  def each
    @values.each { |v| yield v }
  end

  def each_with_index
    @values.each_with_index { |v,i| yield v, i }
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
    @values.map! { |v| yield v }
    @need_update = true
  end

  def map_with_index!
    @values.map_with_index! { |v,i| yield v, i }
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
        bytes = @values.to_unsafe
        texture.update bytes, @size.x, @size.y, 0, 0, Boleite::Texture::Format::Red
        @need_update = false
      end
      return texture
    end
    raise "Failed to create texture for value map"
  end
end
