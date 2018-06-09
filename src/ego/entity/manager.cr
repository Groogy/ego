class EntityManager
  include CrystalClear

  @map : Map
  @grid : EntityGrid
  @entities = [] of Entity
  @renderer = EntityRenderer.new

  getter renderer
  delegate each_at, to: @grid

  def initialize(@map)
    @grid = EntityGrid.new @map.size
  end

  def create_entity(tmpl, pos, world)
    entity = Entity.new tmpl, pos
    @grid.add entity
    @entities << entity
    entity.initialize_components world
    @renderer.notify_change
    entity
  end

  def render(renderer)
    @renderer.render self, @map, renderer
  end

  def each
    @entities.each do |entity|
      yield entity
    end
  end
end