class HarvestGrowthSystem < EntitySystem
  include CrystalClear

  def target_component
    HarvestGrowthComponent
  end

  requires entity.has_component? HarvestableComponent
  def update(world, entity, component)
    component = component.as(HarvestGrowthComponent)
    if component.can_grow?
      component.advance_growth
      if component.can_spawn? entity
        component.spawn_entity world, entity
      end
    end
  end
end
