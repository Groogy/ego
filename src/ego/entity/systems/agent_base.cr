abstract class AgentBaseSystem < EntitySystem
  include CrystalClear

  def update_task(world : World, entity : Entity, component : AgentBaseComponent)
    if task = component.task
      if task.finished? entity, component
        task.finish world, entity, component
        component.reset_task
      end
    end
  end

  requires !component.home.nil?
  def go_home(world : World, entity : Entity, component : AgentBaseComponent)
    if home = component.home
      component.create_task GoHomeTask, world, entity, home
    end
  end
end
