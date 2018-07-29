class Entity
  include CrystalClear

  @id : EntityId
  @template : EntityTemplate
  @position : EntityPos
  @components = [] of EntityComponent
  @destroyed = false

  getter id, template
  property position

  protected property components

  def initialize(@id, @template, @position)
  end

  def initialize_components(world)
    @components = @template.allocate_components
    @components.each_with_index do |obj, index|
      data = @template.get_component_data index
      EntityComponent.initialize_obj obj, data, self, world
    end
  end

  def spawn_setup(world)
    @components.each do |obj|
      obj.spawn_setup self, world
    end
  end

  def has_component?(id : String) : Bool
    @components.each do |obj|
      return true if obj.id == id
    end
    return false
  end

  def has_component?(klass) : Bool
    @components.each do |obj|
      return true if obj.class == klass
    end
    return false
  end

  def get_component?(id : String)
    @components.find do |obj|
      obj.id == id
    end
  end

  def get_component?(klass)
    @components.find do |obj|
      obj.class == klass
    end
  end

  requires has_component? id
  def get_component(id : String)
    comp = get_component? id
    comp.as(EntityComponent)
  end

  requires has_component? klass
  def get_component(klass)
    comp = get_component? klass
    klass.cast comp
  end

  def query(klass)
    comp = get_component? klass
    if comp
      yield klass.cast(comp)
    else
      nil
    end
  end

  def destroy
    @destroyed = true
  end

  def destroyed?
    @destroyed
  end
end
