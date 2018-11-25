class HarvestableComponent < BaseStorageComponent
  include CrystalClear

  def initialize(data, entity, world)
    super data, entity, world
  end

  def difficulty
    HarvestableComponent.difficulty @data
  end

  def self.difficulty(data)
    data.get_int "difficulty"
  end

  requires !@entities.empty?
  def take_any(storage, taker)
    take storage, @entities.first, taker
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
