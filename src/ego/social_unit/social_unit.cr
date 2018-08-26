class SocialUnit
  include CrystalClear

  @id : SocialUnitId
  @name : String
  @members = SocialUnitMemberManager.new

  getter id, name
  protected getter members

  def initialize(@id, @name)
  end

  requires entity.has_component? SocialUnitMemberComponent
  requires !entity.query SocialUnitMemberComponent, &.owner.nil?
  requires !@members.includes? entity
  def register(entity)
    @members.register entity, self
  end

  requires @members.includes? entity
  ensures !@members.includes? entity
  def unregister(entity)
    @members.unregister entity
  end

  def update(world)
    clean_destroyed_members
    survey_land world
  end

  def clean_destroyed_members
    @members.reject! { |e| e.destroyed? }
  end

  def survey_land(world)
    provider = @members.find_agent_provider SurveyorComponent
    path = find_survey_target provider, world
    if path
      agent = request_agent provider, world
      if agent
        agent.query MovingComponent, &.target=(path)
      end
    end
  end

  def request_agent(provider : Nil, world)
    nil
  end

  def request_agent(provider : Entity, world)
    provider.query AgentProviderComponent, &.request_agent(SurveyorComponent, provider, world)
  end

  def find_survey_target(provider : Nil, world)
  end

  def find_survey_target(provider : Entity, world)
    PathFinder.broad_search world, provider.position.point, 10, ->find_interesting_entity(World, Map::Pos)
  end

  def find_interesting_entity(world : World, pos : Map::Pos)
    world.entities.each_at pos do |e|
      return e if e.has_component? SurveyorInterestComponent
    end
    nil
  end
end