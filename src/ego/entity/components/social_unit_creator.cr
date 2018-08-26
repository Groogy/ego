class SocialUnitCreatorComponent < EntityComponent
  include CrystalClear

  requires entity.has_component? SocialUnitMemberComponent
  ensures !entity.query SocialUnitMemberComponent, &.owner.nil?
  def spawn_setup(entity, world)
    if entity.query SocialUnitMemberComponent, &.owner.nil?
      unit = find_or_create_unit world, entity
      unit.register entity
    end
  end

  def find_or_create_unit(world, entity)
    unit = find world, entity
    unit = create world if !unit
    unit
  end

  def find(world, entity)
    entity = PathFinder.broad_search_entity world, entity.position.point, 10, ->find_unit_at_pos(World, Map::Pos)
    if entity
      entity.query SocialUnitMemberComponent, &.owner 
    else
      nil
    end
  end

  def create(world)
    world.social_units.create world
  end

  def find_unit_at_pos(world : World, pos : Map::Pos)
    world.entities.each_at pos do |e|
      return e if !e.query SocialUnitMemberComponent, &.owner.nil?
    end
    nil
  end
end
