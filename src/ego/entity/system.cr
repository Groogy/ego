abstract class EntitySystem
  abstract def update(world, entity, component)
  abstract def target_component
end