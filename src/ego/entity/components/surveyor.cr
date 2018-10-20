class SurveyorComponent < AgentBaseComponent
end

class SurveyTask < AgentTask
  def initialize(@path : Path)
  end

  def start(world, entity, component)
    entity[MovingComponent].target = @path
  end

  def finish(world, entity, component)
    social_unit = entity[SocialUnitMemberComponent].owner!
    pos = entity.position.point
    world.entities.each_at pos do |e|
      if e.has_component? SurveyorInterestComponent
        social_unit.resources.register e, world
      end
    end
  end

  def finished?(entity, component)
    entity.position == @path.last_tile
  end
end