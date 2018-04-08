class EntityTemplate
  include CrystalClear

  @data : EntityTemplateData

  delegate id, name, to: @data

  def initialize(@data : EntityTemplateData)
  end
end