class TileType
  property key, name, uv

  @key : String
  @name : String
  @uv : Boleite::Vector2u

  def initialize(@key, @name, @uv)
  end
end

struct ConstTileType
  delegate key, name, uv, to: @data
  
  def initialize(@data : TileType)
  end
end
