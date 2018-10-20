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

  requires home.has_component? AgentProviderComponent
  def initialize(home : Entity)
    @home = home
  end

  requires entity.has_component? MovingComponent
  requires @home.query AgentProviderComponent, &.owns?(entity)
  def start(world, entity, component)
    path = PathFinder.quick_search world, entity.position.point, @home
    assert path
    entity.query MovingComponent, &.target=(path)
  end

  requires @home.query AgentProviderComponent, &.owns?(entity)
  def finish(world, entity, component)
    @home[AgentProviderComponent].return_agent entity
  end

  def finished?(entity, component)
    entity.position == @home.position
  end
end
