class HungerSystem < EntitySystem
  def update(world, entity, component)
    component = component.as(HungerComponent)
    component.satisfaction -= component.satisfaction_decay
  end

  def target_component
    HungerComponent
  end
end
