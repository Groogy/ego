class SocialUnitCreatorSystem < EntitySystem
  def target_component
    SocialUnitCreatorComponent
  end

  def update(world, entity, component)
    if entity.query SocialUnitMemberComponent, &.owner.nil?
      unit = find_or_create_unit world, entity
      unit.register entity
    end
  end

  def find_or_create_unit(world, entity)
    unit = find_unit world, entity
    unit = create_unit world if !unit
    unit
  end

  def find_unit(world, entity)
    nil
  end

  def create_unit(world)
    world.social_units.create
  end
end
