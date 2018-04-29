abstract struct EntityPos
  abstract def point : Boleite::Vector2u16
  abstract def on_map? : Boolean
  abstract def parent : Entity?

  def x
    point.x
  end

  def y
    point.y
  end
end

struct MapEntityPos < EntityPos
  @pos : Map::Pos

  def initialize(@pos)
  end

  def initialize(pos : Boleite::Vector2u16)
    @pos = Map::Pos.new pos.x, pos.y
  end

  def initialize(x, y)
    @pos = Map::Pos.new x, y
  end

  def point
    @pos
  end

  def on_map?
    true
  end

  def parent
    nil
  end
end

struct OffmapEntityPos < EntityPos
  @parent : Entity

  def initialize(@parent)
  end

  def point
    @parent.position.point
  end

  def on_map?
    false
  end

  def parent
    @parent
  end
end