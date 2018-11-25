abstract class AgentBaseSystem < EntitySystem
  include CrystalClear

  def update_task(world : World, entity : Entity, component)
    if task = component.task
      if task.finished? world, entity, component
        task.finish world, entity, component
        component.reset_task
      elsif task.progress? world, entity, component
        task.progress world, entity, component
      end
    end
  end

  requires !component.home.nil?
  def go_home(world : World, entity : Entity, component)
    if home = component.home
      component.create_task GoHomeTask, world, entity, home
    end
  end
end
