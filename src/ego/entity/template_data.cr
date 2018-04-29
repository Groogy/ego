struct EntityTemplateData
  @id : String
  @name = ""
  @categories = [] of String
  @graphics = EntityGraphicsTemplate.new

  property id, name, categories, graphics

  def initialize(@id)
  end
end