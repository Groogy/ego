class MovingSystem < EntitySystem
  def target_component
    MovingComponent
  end

  def update(world, entity, component)
    component = component.as(MovingComponent)
    if target = component.target
      if entity.position.point == target.last_tile
        reset_movement component
      else
        update_movement world, entity, target, component
      end
    end
  end

  def update_movement(world, entity, target : Path, component : MovingComponent)
    component.progress += component.speed
    cost = world.movement_cost entity.position.point, target.next_tile
    if component.progress >= cost
      component.progress -= cost
      world.entities.move entity, target.next_tile
      target.progress
    end
  end

  def reset_movement(component)
    component.progress = 0.0
    component.target = nil
  end
end
