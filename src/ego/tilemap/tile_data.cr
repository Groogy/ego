class TileData
  property tile_type, height, ramp

  @tile_type : TileType?
  @height = 0u16
  @ramp = false

  def is_ramp?
    @ramp
  end
end

struct ConstTileData
  delegate height, ramp, is_ramp?, to: @data
  
  def initialize(@data : TileData)
  end

  def tile_type
    if type = @data.tile_type
      ConstTileType.new type
    else
      nil
    end
  end
end