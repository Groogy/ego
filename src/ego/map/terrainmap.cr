class Terrainmap
  include CrystalClear

  @terrain = {} of Boleite::Colori => TerrainType
  @texture : Boleite::Texture?
  @cache : Boleite::Image
  @need_update = true

  def initialize(@size : Boleite::Vector2u)
    @cache = Boleite::Image.new @size.x, @size.y
  end

  def fill_with(terrain : TerrainType)
    @terrain[terrain.color] = terrain
    @cache.fill terrain.color
    @need_update = true
  end

  macro pos_to_index(pos)
    pos.x + pos.y * @size.x
  end
  
  requires inside? pos
  def get_terrain?(pos) : TerrainType?
    color = @cache.get_pixel pos.x, pos.y
    @terrain[color]?
  end

  def get_terrain(pos)
    terrain = get_terrain? pos
    raise "Nil terrain at #{pos}" unless terrain
    terrain
  end

  def get_terrain?(x, y)
    get_terrain? Boleite::Vector2u.new x, y
  end

  def get_terrain(x, y)
    get_terrain Boleite::Vector2u.new x, y
  end

  requires inside? pos
  def set_terrain(pos, terrain : TerrainType?)
    index = pos_to_index pos
    color = Color.black
    if terrain
      color = terrain.color
      @terrain[color] = terrain
    end
    @cache.set_pixel pos.x, pos.y, color
    @need_update = true
  end

  def []?(pos)
    get_terrain? pos
  end

  def [](pos)
    get_terrain pos
  end

  def []=(pos, terrain)
    set_terrain pos, terrain
  end

  def inside?(pos)
    pos.x >= 0 && pos.x < @size.x && pos.y >= 0 && pos.y < @size.y
  end

  def generate_texture(gfx) : Boleite::Texture
    unless @texture
      texture = gfx.create_texture
      texture.create @size.x, @size.y, Boleite::Texture::Format::RGBA, Boleite::Texture::Type::Integer8
      texture.smooth = false
      texture.repeating = false
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