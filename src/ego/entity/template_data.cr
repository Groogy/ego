class EntityTemplateData
  @id : String
  @name = ""
  @categories = [] of String
  @graphics = EntityGraphicsTemplate.new
  @components = [] of EntityComponentData

  getter id, name, categories, graphics, components
  protected setter id, name, categories, graphics, components

  def initialize(@id)
  end
end