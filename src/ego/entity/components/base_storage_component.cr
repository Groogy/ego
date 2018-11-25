abstract class BaseStorageComponent < EntityComponent
  include CrystalClear

  @entities = [] of Entity

  protected property entities

  delegate each, sum, any?, empty?, to: @entities

  requires can_store? storage, entity
  requires !@entities.includes? entity
  ensures entity.position.point == storage.position.point
  def store(storage, entity : Entity)
    entity.position = OffmapEntityPos.new(storage)
    @entities << entity
  end

  requires can_take? storage, entity, taker
  requires @entities.includes? entity
  def take(storage, entity, taker)
    @entities.delete entity
  end

  requires has? tmpl
  def take(storage, tmpl : EntityTemplate, taker)
    e = @entities.find { |e| e.template == tmpl }
    take storage, e, taker
  end

  def count
    @entities.size
  end

  def count
    @entities.count { |e| yield e }
  end

  def has?(tmpl : EntityTemplate)
    any? { |e| e.template == tmpl }
  end

  def has?(n : Nil)
    false
  end

  def calculate_volume
    sum { |e| e.query MassComponent, &.volume || 0.0 }
  end

  def calculate_volume_with(tmpl : EntityTemplate)
    volume = calculate_volume
    if tmpl.has_component? "mass"
      volume += MassComponent.volume tmpl.get_component_data("mass")
    end
    volume
  end

  def calculate_weight
    sum { |e| e.query MassComponent, &.weight || 0.0 }
  end

  def calculate_weight_with(tmpl : EntityTemplate)
    weight = calculate_weight
    if tmpl.has_component? "mass"
      weight += MassComponent.weight tmpl.get_component_data("mass")
    end
    weight
  end

  abstract def can_store?(storage, entity : Entity)
  abstract def can_store?(storage, tmpl : EntityTemplate)
  abstract def can_take?(storage, entity, taker)
end

