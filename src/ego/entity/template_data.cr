struct EntityTemplateData
  @id : String
  @name = ""
  @categories = [] of String

  property id, name, categories

  def initialize(@id)
  end
end