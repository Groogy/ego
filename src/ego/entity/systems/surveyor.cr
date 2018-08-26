class SurveyorSystem < EntitySystem
  def target_component
    SurveyorComponent
  end

  def update(world, entity, component)
    component = component.as(SurveyorComponent)
    moving = entity.get_component MovingComponent
    target = moving.target
    if target && target.last_tile == entity.position
      moving.target = nil
    elsif target.nil?
      survey_land world, entity, moving
    end
  end

  def survey_land(world, entity, moving)
    path = SurveyorSystem.find_survey_target entity, world
    SurveyorSystem.set_survey_path moving, path
  end

  def self.set_survey_path(moving, path)
    moving.target = path
  end

  def self.find_survey_target(entity : Nil, world)
    nil
  end

  def self.find_survey_target(entity : Entity, world)
    PathFinder.broad_search world, entity.position.point, 10, ->find_interesting_entity(World, Map::Pos)
  end

  def self.find_interesting_entity(world : World, pos : Map::Pos)
    world.entities.each_at pos do |e|
      return e if e.has_component? SurveyorInterestComponent
    end
    nil
  end
end
