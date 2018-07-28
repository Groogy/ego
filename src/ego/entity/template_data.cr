class EntityTemplateData
  @id : String
  @name = ""
  @description = ""
  @size = Boleite::Vector2i.one
  @categories = [] of String
  @graphics = EntityGraphicsTemplate.new
  @components = [] of EntityComponentData

  getter id, name, description, size, categories, graphics, components
  protected setter id, name, description, size, categories, graphics, components

  def initialize(@id)
  end
end