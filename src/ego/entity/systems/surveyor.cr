class SurveyorSystem < AgentBaseSystem
  def target_component
    SurveyorComponent
  end

  requires entity.has_component? MovingComponent
  requires entity.query SocialUnitMemberComponent, &.owner
  def update(world, entity, component)
    component = component.as(SurveyorComponent)
    if component.task
      update_task world, entity, component
    else
      found = survey_land world, entity, component
      go_home world, entity, component unless found
    end
  end

  def survey_land(world, entity, component)
    unit = entity[SocialUnitMemberComponent].owner!
    path = SurveyorSystem.find_survey_target entity, world, unit
    SurveyorSystem.set_survey_path world, entity, component, path
    !path.nil?
  end

  def self.set_survey_path(world : World, entity : Entity, component : AgentBaseComponent, path : Path)
    component.create_task SurveyTask, world, entity, path
  end

  def self.set_survey_path(world : World, entity : Entity, component : AgentBaseComponent, path : Nil)
    component.reset_task
  end

  def self.find_survey_target(entity : Entity, world : World, social_unit : SocialUnit)
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
