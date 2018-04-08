class EntityTemplate
  include CrystalClear

  @id : String
  @name : String

  getter id, name

  def initialize(data : EntityTemplateData)
    @id = data.id
    @name = data.name
  end
end