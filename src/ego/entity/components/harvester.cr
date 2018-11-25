class HarvesterComponent < AgentBaseComponent
  @area : Array(Map::Pos)?
  @target_tmpl : EntityTemplate?
  @container : BaseStorageComponent

  getter area, target_tmpl, container
  protected setter area, target_tmpl

  def initialize(data, entity, world)
    super data, entity, world

    key = data.get_string "container"
    @container = entity.get_component(key).as(BaseStorageComponent)
  end

  def set_work_area(world, area, @target_tmpl)
    grid = world.entities.grid
    @area = area.reject! do |pos|
      !grid.find_at(pos) { |e| e.template == @target_tmpl && e[HarvestableComponent].count > 0 }
    end
  end

  def reset_work_area
    @area = nil
    @target_tmpl = nil
  end
  
  def skill
    @data.get_int "skill"
  end
end

class HarvestTask < AgentTask
  include CrystalClear

  @progress = 0
  @container : Entity?
  @finished = false

  getter progress, container
  protected setter progress, container
  
  def initialize
  end

  requires component.is_a? HarvesterComponent
  requires !component.area.nil?
  ensures !entity[MovingComponent].target.nil?
  def start(world, entity, component)
    if area = component.area
      tile = area.first
      path = PathFinder.quick_search world, entity.position.point, tile
      entity[MovingComponent].target = path
    end
  end

  def progress?(world, entity, component)
    path = entity[MovingComponent].target
    return @container || (path && entity.position == path.last_tile)
  end

  def progress(world, entity, component : HarvesterComponent)
    if container = @container
      progress_harvest container, entity, component
    end
    progress_harvest_container world, entity, component
  end

  protected def progress_harvest(container, entity, component)
    @progress += component.skill
    harvestable = container[HarvestableComponent]
    if @progress > harvestable.difficulty
      harvest = harvestable.take_any container, entity
      component.container.store entity, harvest if harvest
      social_unit = entity[SocialUnitMemberComponent].owner
      if social_unit
        social_unit.resources.reduce component.target_tmpl, entity.position.point, 1
      end
      @progress = 0
    end
  end

  protected def progress_harvest_container(world, entity, component)
    if container = @container
      harvestable = container[HarvestableComponent]
      if harvestable.count <= 0
        find_new_harvest_container world, entity, component
      else
        item = harvestable.first
        @container = nil if !component.container.can_store? entity, item
      end
    else
      find_new_harvest_container world, entity, component
    end
    @finished = @container.nil?
  end

  protected def find_new_harvest_container(world, entity, component)
    @container = world.entities.find_at(entity.position) do |e|
      e.template == component.target_tmpl && e[HarvestableComponent].count > 0
    end
  end

  requires !component.area.nil?
  def finish(world, entity, component : HarvesterComponent)
    if area = component.area
      area.shift
    end
  end

  def finished?(world, entity, component)
    @finished
  end

  def progress(world, entity, component)
    raise "Got wrong component for progressing HarvestTask"
  end

  def finish(world, entity, component)
    raise "Got wrong component for finishing HarvestTask"
  end
end