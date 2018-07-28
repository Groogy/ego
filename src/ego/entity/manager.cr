class EntityManager
  include CrystalClear

  @map : Map
  @grid : EntityGrid
  @entities = [] of Entity
  @systems = [] of EntitySystem
  @descriptors = [] of EntityDescriptor
  @renderer = EntityRenderer.new
  @id_generator : EntityIdGenerator

  getter renderer, grid
  delegate each_at, to: @grid
  delegate each, each_with_index, to: @entities

  protected property entities, id_generator

  def initialize(@map, @id_generator = EntityIdGenerator.new)
    @grid = EntityGrid.new @map.size
    create_systems
    create_descriptors
  end

  def create_systems
    {% for klass in EntitySystem.all_subclasses %}
      {% unless klass.abstract? %}
    @systems << {{ klass }}.new
      {% end %}
    {% end %}
  end

  def create_descriptors
    {% for klass in EntityDescriptor.all_subclasses %}
      {% unless klass.abstract? %}
    @descriptors << {{ klass }}.new
      {% end %}
    {% end %}
  end

  requires @grid.inside? pos, tmpl.size
  def create(tmpl, pos, world)
    entity = Entity.new @id_generator.generate, tmpl, pos
    @grid.add entity if pos.on_map?
    @entities << entity
    entity.initialize_components world
    entity.spawn_setup world
    @renderer.notify_change
    entity
  end

  def add(entity)
    @grid.add entity if entity.position.on_map?
    @entities << entity
    @renderer.notify_change
    entity
  end

  def find_by_id(id : EntityId)
    each do |entity|
      return entity if entity.id == id
    end
    nil
  end

  def exists_by_id?(id : EntityId)
    each do |entity|
      return true if entity.id == id
    end
    false
  end

  def find_descriptors_for(tmpl : EntityTemplate)
    @descriptors.compact_map do |desc|
      desc if desc.applies_to? tmpl
    end
  end

  def update(world)
    @systems.each do |system|
      update_system world, system
    end
    clean_destroyed_entities
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

  def clean_destroyed_entities
    @entities.reject! do |entity|
      entity.destroyed?
    end
  end

  def render(renderer)
    @renderer.render self, @map, renderer
  end
end