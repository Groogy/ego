class PopulationSystem < EntitySystem
  def target_component
    PopulationComponent
  end

  def update(world, entity, component)
    component = component.as(PopulationComponent)
    update_growth entity, component
  end

  def update_growth(entity, component)
    component.advance_growth
  end
end
