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

    update_food world
  end

  def update_food(world)
    hungry_members = @members.select { |m| m.has_component? HungerComponent }
    if needs_food?
      source = find_food_source(world)
      source.gather self, world if source
    end
    feed_members world, hungry_members
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
        agent = request_agent provider, SurveyorComponent, world
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

  requires hungry_members.all? { |e| e.has_component? HungerComponent }
  def feed_members(world, hungry_members)
    hungry_members.each do |e|
      hunger = e[HungerComponent]
      if hunger.want_food?
        food = find_food_item hunger.edible
        hunger.eat food if food
      end
    end
  end

  def request_agent(klass, world)
    provider = @members.find_agent_provider SurveyorComponent
    request_agent provider, klass, world
  end

  def find_empty_storage_for(item)
    @members.each_storage do |entity|
      storage = entity.get_component_of_base BaseStorageComponent
      return entity if storage.can_store? entity, item
    end
    return nil
  end

  def find_food_item(categories)
    foods = [] of Entity
    @members.each_storage do |storage|
      component = storage.get_component_of_base BaseStorageComponent
      foods += component.select { |e| e.template.any_category?(categories) && e.has_component?(FoodComponent) }
    end
    foods.sort! { |a, b| a[FoodComponent].hunger_worth <=> b[FoodComponent].hunger_worth }
    if foods.empty?
      nil
    else
      foods.first
    end
  end

  protected def request_agent(provider : Nil, klass, world)
    nil
  end

  protected def request_agent(provider : Entity, klass, world)
    agent = provider.query AgentProviderComponent, &.request_agent(klass, provider, world)
    if agent
      register agent
    end
    agent
  end

  invariant !@members.any? &.destroyed?
end