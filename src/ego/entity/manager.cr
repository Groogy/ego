class EntityManager
  include CrystalClear

  @map : Map
  @grid : EntityGrid
  @entities = [] of Entity
  @systems = [] of EntitySystem
  @renderer = EntityRenderer.new

  getter renderer
  delegate each_at, to: @grid

  def initialize(@map)
    @grid = EntityGrid.new @map.size
    create_systems
  end

  def create_systems
    {% for klass in EntitySystem.subclasses %}
    @systems << {{ klass }}.new
    {% end %}
  end

  def create_entity(tmpl, pos, world)
    entity = Entity.new tmpl, pos
    @grid.add entity
    @entities << entity
    entity.initialize_components world
    @renderer.notify_change
    entity
  end

  def update(world)
    @systems.each do |system|
      update_system world, system
    end
  end

  def update_system(world, system)
    wanted_component = system.target_component
    @entities.each do |entity|
      component = entity.get_component? wanted_component
      if component
        system.update world, entity, component
      end
    end
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