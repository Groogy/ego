class SurveyorSystem < AgentBaseSystem
  def target_component
    SurveyorComponent
  end

  requires entity.has_component? MovingComponent
  requires entity.query SocialUnitMemberComponent, &.owner
  def update(world, entity, component)
    component = component.as(SurveyorComponent)
    moving = entity.get_component MovingComponent
    target = moving.target
    social_unit = entity.query SocialUnitMemberComponent, &.owner
    return if !social_unit
    if target && target.last_tile == entity.position
      survey_tile world, entity, moving, social_unit
    elsif target.nil?
      found = survey_land world, entity, moving, social_unit
      go_home world, entity, component, moving unless found
    end
  end

  def survey_tile(world, entity, moving, social_unit)
    pos = entity.position.point
    world.entities.each_at pos do |e|
      if e.has_component? SurveyorInterestComponent
        social_unit.resources.register e, world
      end
    end
    moving.target = nil
  end

  def survey_land(world, entity, moving, social_unit)
    path = SurveyorSystem.find_survey_target entity, world, social_unit
    SurveyorSystem.set_survey_path moving, path
    !path.nil?
  end

  def self.set_survey_path(moving, path)
    moving.target = path
  end

  def self.find_survey_target(entity : Nil, world, social_unit)
    nil
  end

  def self.find_survey_target(entity : Entity, world, social_unit)
    resources = social_unit.resources
    proc = ->(w : World, p : Map::Pos) do
      w.entities.each_at p do |e|
        if e.has_component? SurveyorInterestComponent
          break e unless resources.contains? p, e.template
        end
      end
    end
    PathFinder.broad_search world, entity.position.point, 10, proc
  end
end
