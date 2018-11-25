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
  abstract def finished?(world, entity, component)
  
  def progress?(world, entity, component)
    false
  end

  def progress(world, entity, component)
  end
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

  def finished?(world, entity, component)
    entity.position == @home.position
  end
end

class UnloadTask < AgentTask
  include CrystalClear

  getter storage

  requires storage.is_component_a? BaseStorageComponent
  def initialize(storage : Entity)
    @storage = storage
  end

  requires entity.has_component? MovingComponent
  requires entity.is_component_a? BaseStorageComponent
  def start(world, entity, component)
    path = PathFinder.quick_search world, entity.position.point, @storage
    assert path
    entity.query MovingComponent, &.target=(path)
  end

  def finish(world, entity, component)
    carries = find_storages entity
    storages = find_storages @storage
    carries.each do |c|
      c.each do |i|
        try_store entity, c, i, storages
      end
    end
  end

  def find_storages(entity)
    storages = entity.select_components { |c| c.is_a? BaseStorageComponent }
    storages.map { |c| c.as(BaseStorageComponent) }
  end

  def try_store(entity, carry, item, storages)
    storages.each do |s|
      if s.can_store? @storage, item
        i = carry.take entity, item, entity
        assert i == item
        s.store @storage, item
      end
    end
  end

  def finished?(world, entity, component)
    entity.position == @storage.position
  end
end