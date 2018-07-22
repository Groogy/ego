class HarvestableComponent < BaseStorageComponent
  include CrystalClear

  def initialize(data, entity, world)
    super data, entity, world
    start = data.get_array("start")
    start.each do |key|
      tmpl = world.entity_templates.get key.to_s
      harvest = world.spawn_entity tmpl, OffmapEntityPos.new(entity)
      store entity, harvest
    end
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
