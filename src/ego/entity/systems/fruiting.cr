class FruitingSystem < EntitySystem
  def target_component
    FruitingComponent
  end

  def update(world, entity, component)
    component = component.as(FruitingComponent)
    if component.can_grow?
      component.advance_growth
      if component.can_spawn? entity
        component.spawn_entity world, entity
      end
    end
  end
end
