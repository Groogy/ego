class SocialUnit
  include CrystalClear

  @id : SocialUnitId
  @name : String
  @members = SocialUnitMemberManager.new
  @resources = SocialUnitResourceTracker.new

  getter id, name, resources
  protected getter members
  protected setter resources

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
    @resources.update world
    survey_land world if should_survey? world
    if needs_food?
      source = find_food_source(world)
      source.gather self, world if source
    end
  end

  def should_survey?(world)
    world_tick = world.current_tick
    days_tick = GameTime.new
    days_tick.add_days world_tick.to_days
    tick = world_tick - days_tick
    target = GameTime.new
    target.add_hours 9
    tick == target
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

  def needs_food?
    true
  end

  def find_food_source(world)
    sources = [] of FoodSource
    @resources.each_area do |area|
      next if area.quantity <= 0
      tmpl = area.resource
      if tmpl.has_component? FoodSourceComponent
        sources << FoodSourceComponent.create_source area
      elsif tmpl.has_component? FoodComponent
        sources << PickupFoodSource.new area.tiles.dup, area.resource, area.quantity
      end
    end
    sources.sort! { |a,b| a.score <=> b.score }
    sources.first unless sources.empty?
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