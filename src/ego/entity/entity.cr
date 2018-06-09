class Entity
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
end