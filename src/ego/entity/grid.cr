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

    def each
      @entities.each do |entity|
        yield entity
      end
    end

    def find
      @entities.find do |entity|
        yield entity
      end
    end

    def any?
      @entities.any? do |entity|
        yield entity
      end
    end

    invariant !any? { |e| e.destroyed? }
  end

  @size : Boleite::Vector2i
  @grid : Array(Bucket)

  getter size

  def initialize(@size)
    count = @size.x * @size.y
    @grid = Array.new(count) { Bucket.new }
  end

  requires inside? pos, entity.template.size
  requires !includes? entity
  ensures includes? entity, pos
  def add(entity, pos)
    size = entity.template.size
    size.y.times do |y|
      size.x.times do |x|
        @grid[pos.x + x + (pos.y + y) * @size.y].add entity
      end
    end
  end

  def add(entity)
    add entity, entity.position
  end

  requires inside? pos, entity.template.size
  requires includes? entity
  ensures !includes? entity
  def remove(entity, pos)
    size = entity.template.size
    size.y.times do |y|
      size.x.times do |x|
        @grid[pos.x + x + (pos.y + y) * @size.y].remove entity
      end
    end
  end

  def remove(entity)
    remove entity, entity.position
  end

  requires pos != entity.position
  def move(entity, pos)
    remove entity
    entity.position = MapEntityPos.new pos
    add entity
  end

  def inside?(pos, size)
    pos.x >= 0 && pos.y >= 0 && pos.x + (size.x - 1) < @size.x && pos.y + (size.y - 1) < @size.y
  end

  def includes?(entity)
    @grid.any? &.includes?(entity)
  end

  def includes?(entity, pos)
    @grid[pos.x + pos.y * @size.y].includes? entity
  end

  def each_at(pos)
    @grid[pos.x + pos.y * @size.y].each do |entity|
      yield entity
    end
  end

  def find_at(pos)
    @grid[pos.x + pos.y * @size.y].find do |entity|
      yield entity
    end
  end
end