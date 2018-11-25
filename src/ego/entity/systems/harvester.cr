class HarvesterSystem < AgentBaseSystem
  def target_component
    HarvesterComponent
  end

  requires entity.has_component? MovingComponent
  requires entity.query SocialUnitMemberComponent, &.owner
  def update(world, entity, component)
    component = component.as(HarvesterComponent)
    if component.task
      update_task world, entity, component
    elsif component.container.count > 0
      unload_container world, entity, component
    else
      go_home world, entity, component
    end
  end

  def unload_container(world, entity, component)
    social_unit = entity[SocialUnitMemberComponent].owner!
    item = component.container.first
    container = social_unit.find_empty_storage_for item
    if container
      component.create_task UnloadTask, world, entity, container
    else
      go_home world, entity, component
    end
  end

  def self.set_harvest_work_area(world : World, entity : Entity, component : AgentBaseComponent, area : Array(Map::Pos), target : EntityTemplate)
    component.set_work_area world, area, target
    component.create_task HarvestTask, world, entity
  end
end
