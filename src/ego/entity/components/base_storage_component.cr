abstract class BaseStorageComponent < EntityComponent
  include CrystalClear

  @entities = [] of Entity

  protected property entities

  delegate each, empty?, to: @entities

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

  def count
    @entities.size
  end

  abstract def can_store?(storage, entity : Entity)
  abstract def can_store?(storage, tmpl : EntityTemplate)
  abstract def can_take?(storage, entity, taker)
end

