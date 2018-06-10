class HarvestableSystem < EntitySystem
  def target_component
    HarvestableComponent
  end

  def update(world, entity, component)
    component = component.as(HarvestableComponent)
    if !component.can_harvest?
      component.increase_time_since_harvest
      if component.time_since_harvest >= component.growth_time
        component.create_entity world, entity
      end
    end
  end

  def update_growth(entity, component)
    component.advance_growth
  end
end
