class Entity
  include CrystalClear

  @template : EntityTemplate
  @position : EntityPos
  @components = [] of EntityComponent

  getter template, position

  def initialize(@template, @position)
  end

  def initialize_components(world)
    @components = @template.allocate_components
    @components.each_with_index do |obj, index|
      data = @template.get_component_data index
      EntityComponent.initialize_obj obj, data, self, world
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
    @components.each do |obj|
      return obj if obj.id == id
    end
    return nil
  end

  def get_component?(klass)
    @components.each do |obj|
      return obj if obj.class == klass
    end
    return nil
  end

  requires has_component? id
  def get_component(id : String)
    comp = get_component? id
    comp.as(EntityComponent)
  end

  requires has_component? klass
  macro get_component(klass)
    comp = get_component? klass
    comp.as(EntityComponent)
  end
end