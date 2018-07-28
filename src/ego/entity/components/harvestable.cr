class HarvestableComponent < BaseStorageComponent
  include CrystalClear

  def initialize(data, entity, world)
    super data, entity, world
  end

  def can_store?(storage, entity : Entity)
    true
  end
  
  def can_store?(storage, tmpl : EntityTemplate)
    true
  end

  def can_take?(storage, entity, taker)
    true
  end
end
