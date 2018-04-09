class EntityGrid
  include CrystalClear

  class Bucket
    include CrystalClear

    @entities = [] of Entity

    requires !includes? entity
    def add(entity)
      @entities << entity
    end

    requires includes? entity
    ensures !includes? entity
    def remove(entity)
      @entities.delete entity
    end

    def includes?(obj)
      @entities.includes? obj
    end
  end

  @size : Boleite::Vector2i
  @grid : Array(Bucket)

  getter size

  def initialize(@size)
    count = @size.x * @size.y
    @grid = Array.new(count) { Bucket.new }
  end

  requires inside? entity.position
  requires !includes? entity
  def add(entity)
    pos = entity.position
    @grid[pos.x + pos.y * @size.y].add entity
  end

  requires inside? entity.position
  requires includes? entity
  def remove(entity)
    pos = entity.position
    @grid[pos.x + pos.y * @size.y].remove entity
  end

  requires old != entity.position
  requires inside? old && inside? entity.position
  requires includes? entity, old
  ensures includes? entity, entity.position
  def move(old, entity)
    new = entity.position
    @grid[old.x + old.y * @size.y].remove entity
    @grid[new.x + new.y * @size.y].add entity
  end

  def inside?(pos)
    pos.x >= 0 && pos.y >= 0 && pos.x < @size.x && pos.y < @size.y
  end

  def includes?(entity)
    @grid.each &.includes?(entity)
  end

  def includes?(entity, pos)
    @grid[pos.x + old.y * @size.y].includes? entity
  end
end