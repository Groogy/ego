class EntityTemplateData
  @id : String
  @name = ""
  @size = Boleite::Vector2i.one
  @categories = [] of String
  @graphics = EntityGraphicsTemplate.new
  @components = [] of EntityComponentData

  getter id, name, size, categories, graphics, components
  protected setter id, name, size, categories, graphics, components

  def initialize(@id)
  end
end