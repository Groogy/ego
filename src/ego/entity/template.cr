class EntityTemplate
  include CrystalClear

  @data : EntityTemplateData
  @categories = [] of EntityCategory

  delegate id, name, to: @data
  protected getter data
  protected property categories

  def initialize(@data : EntityTemplateData)
  end

  def primary_category
    @categories.first
  end
end