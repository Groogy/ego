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

  def load_task(t : AgentTask)
    @task = t
  end
end

abstract class AgentTask
  def self.find_class(id)
    {% for klass in @type.all_subclasses %}
      {% unless klass.abstract? %}
    return {{ klass }} if {{ klass }}.to_s == id
      {% end %}
    {% end %}
  end

  abstract def start(world, entity, component)
  abstract def finish(world, entity, component)
  abstract def finished?(entity, component)
end

class GoHomeTask < AgentTask
  include CrystalClear

  getter home

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
    @home[AgentProviderComponent].return_agent entity, world
  end

  def finished?(entity, component)
    entity.position == @home.position
  end
end
