class SocialUnit
  include CrystalClear

  @id : SocialUnitId
  @name : String
  @members = SocialUnitMemberManager.new
  @resources = SocialUnitResourceTracker.new

  getter id, name, resources
  protected getter members

  def initialize(@id, @name)
  end

  requires entity.has_component? SocialUnitMemberComponent
  requires entity.query SocialUnitMemberComponent, &.owner.nil?
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
    survey_land world
  end

  def survey_land(world)
    provider = @members.find_agent_provider SurveyorComponent
    if provider
      path = SurveyorSystem.find_survey_target provider, world, self
      if path
        agent = request_agent provider, world
        if agent
          component = agent.get_component SurveyorComponent
          SurveyorSystem.set_survey_path world, agent, component, path
        end
      end
    end
  end

  def request_agent(provider : Nil, world)
    nil
  end

  def request_agent(provider : Entity, world)
    agent = provider.query AgentProviderComponent, &.request_agent(SurveyorComponent, provider, world)
    if agent
      register agent
    end
    agent
  end

  invariant !@members.any? &.destroyed?
end