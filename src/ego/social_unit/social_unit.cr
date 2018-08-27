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
    path = SurveyorSystem.find_survey_target provider, world
    if path
      agent = request_agent provider, world
      if agent
        moving = agent.get_component MovingComponent
        SurveyorSystem.set_survey_path moving, path
      end
    end
  end

  def request_agent(provider : Nil, world)
    nil
  end

  def request_agent(provider : Entity, world)
    agent = provider.query AgentProviderComponent, &.request_agent(SurveyorComponent, provider, world)
    if agent
      agent.query SocialUnitMemberComponent, &.owner=(self)
    end
    agent
  end
end