class Terrainmap
  @terrain : Array(TerrainType?)
  @texture : Boleite::Texture?
  @cache : Boleite::Image
  @need_update = true

  def initialize(@size : Boleite::Vector2u)
    @terrain = Array(TerrainType?).new @size.x * @size.y, nil
    @cache = Boleite::Image.new @size.x, @size.y
  end

  def fill_with(terrain : TerrainType)
    @terrain.fill terrain
    @cache.fill terrain.color
    @need_update = true
  end

  macro pos_to_index(pos)
    pos.x + pos.y * @size.x
  end

  def [](pos)
    index = pos_to_index pos
    @terrain[index]
  end

  def []=(pos, terrain : TerrainType?)
    index = pos_to_index pos
    @terrain[index] = terrain
    color = Color.black
    color = terrain.color if terrain
    @cache.set_pixel pos.x, pos.y, color
    @need_update = true
  end

  def generate_texture(gfx) : Boleite::Texture
    unless @texture
      texture = gfx.create_texture
      texture.create @size.x, @size.y, Boleite::Texture::Format::RGBA, Boleite::Texture::Type::Integer8
      @texture = texture
    end

    if (texture = @texture)
      if @need_update
        texture.update @cache
        @need_update = false
      end
      return texture
    end
    raise "Failed to create texture for terrain map"
  end
end