class Tilemap
  include CrystalClear

  invariant @tiles.size == @size.x * @size.y
  invariant @tiles.all? { |tile| @types.includes? tile.tile_type }

  MAX_HEIGHT_LEVEL = 10
  TILE_SIZE = 16

  @tiles : Array(TileData)
  @types = [] of TileType
  @size = Boleite::Vector2u.zero
  @renderer : TilemapRenderer

  getter size

  def initialize(@size, tileset)
    @tiles = Array(TileData).new @size.x * @size.y do
      TileData.new
    end
    @renderer = TilemapRenderer.new @size, tileset
  end

  requires coord.x < @size.x && coord.y < @size.y
  requires @types.includes? type
  def set_tile(coord : Boleite::Vector2u, type : TileType)
    tile = access_tile_data coord
    tile.tile_type = type
    @renderer.notify_change
  end

  requires coord.x < @size.x && coord.y < @size.y
  requires height <= MAX_HEIGHT_LEVEL
  requires !access_tile_data(coord).tile_type.nil?
  def set_tile_height(coord : Boleite::Vector2u, height : UInt16, ramp : Bool)
    tile = access_tile_data coord
    tile.height = height
    tile.ramp = ramp
    @renderer.notify_change
  end

  requires coord.x < @size.x && coord.y < @size.y
  def get_tile(coord : Boleite::Vector2u)
    tile = access_tile_data coord
    ConstTileData.new tile
  end

  def get_tile(x, y)
    get_tile Boleite::Vector2u.new(x, y)
  end

  def add_tile_type(type)
    @types << type
  end

  def each_tile
    @tiles.each_index do |index|
      yield ConstTileData.new(@tiles[index]), to_coord(index)
    end
  end

  def cleanup_ramps
    @tiles.each_index do |index|
      tile = @tiles[index]
      if tile.is_ramp?
        surrounding = get_surrounding_tiles to_coord(index)
        tile.ramp = false if surrounding.all? { |other| other ? other.height <= tile.height : false }
      end
    end
  end

  def render(renderer)
    @renderer.render self, renderer
  end

  requires coord.x < @size.x && coord.y < @size.y
  def get_surrounding_tiles(coord)
    north, south, east, west = nil, nil, nil, nil
    north = get_tile coord.x, coord.y + 1 if coord.y + 1 < @size.y
    south = get_tile coord.x, coord.y - 1 if coord.y > 0
    east  = get_tile coord.x + 1, coord.y if coord.x + 1 < @size.x
    west  = get_tile coord.x - 1, coord.y if coord.x > 0
    {north, east, south, west}
  end

  requires coord.x < @size.x && coord.y < @size.y
  private def access_tile_data(coord)
    @tiles[to_index(coord)]
  end

  private def to_index(coord)
    coord.x + coord.y * @size.x
  end

  private def to_coord(index)
    Boleite::Vector2u.new index.to_u32 % @size.x, index.to_u32 / @size.y
  end
end