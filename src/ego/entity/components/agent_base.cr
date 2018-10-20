abstract class AgentBaseComponent < EntityComponent
  property home : Entity?
  getter task : AgentTask?

  def reset_task
    @task = nil
  end

  def create_task(klass, world, entity, *args)
    task = klass.new *args
    task.start world, entity, self
    @task = task
  end
end

abstract class AgentTask
  abstract def start(world, entity, component)
  abstract def finish(world, entity, component)
  abstract def finished?(entity, component)
end

class GoHomeTask < AgentTask
  include CrystalClear

  def initialize(@home : Entity)
  end

  requires entity.has_component? MovingComponent
  def start(world, entity, component)
    path = PathFinder.quick_search world, entity.position.point, @home
    assert path
    entity.query MovingComponent, &.target=(path)
  end

  def finish(world, entity, component)
  end

  def finished?(entity, component)
    entity.position == @home.position
  end
end
