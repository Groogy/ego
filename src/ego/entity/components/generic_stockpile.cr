class GenericStockpileComponent < BaseStorageComponent
  include CrystalClear

  def initialize(data, entity, world)
    super data, entity, world
  end

  def max_volume
    @data.get_float "max_volume"
  end

  def allows?(category_tag : String)
    @data.get_array("allows").includes? category_tag
  end

  def allows?(category : EntityCategory)
    allows? category.id
  end

  def allows?(tmpl : EntityTemplate)
    tmpl.any_category? { |cat| allows? cat }
  end

  def get_allowed_categories(world)
    categories = world.entity_categories
    cats = @data.get_array("allows")
    cats.map { |s| categories.get s }
  end

  def can_store?(storage, entity : Entity)
    can_store? storage, entity.template
  end
  
  def can_store?(storage, tmpl : EntityTemplate)
    allows?(tmpl) && calculate_volume_with(tmpl) < max_volume
  end

  def can_take?(storage, entity, taker)
    true
  end
end
