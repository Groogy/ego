class AgentProviderComponent < EntityComponent
  include CrystalClear

  abstract struct BaseDefinition
    @index : Int32
    @agent : EntityTemplate
    @max : Int32

    getter index, agent, max

    def initialize(@index, @agent, @max)
    end

    abstract def component
  end

  struct Definition(T) < BaseDefinition
    def initialize(index, @klass : T, agent, max)
      super index, agent, max
    end

    def component
      @klass
    end
  end

  class Instance
    @instances = [] of Entity

    delegate includes?, to: @instances

    def request_agent(d, owner, world)
      return nil if count >= d.max
      @instances << world.spawn_entity d.agent, owner.position
      @instances.last
    end

    def return_agent(d, entity)
      entity.destroy
      @instances.delete entity
    end

    def count
      @instances.size
    end
  end

  @definitions = [] of BaseDefinition
  @instances : Array(Instance)

  def initialize(data, entity, world)
    super data, entity, world
    entities = world.entity_templates
    data.each do |k, v|
      v = v.as(Hash(String, EntityComponentData::DataType))
      klass = EntityComponent.find_class k
      assert klass != nil
      tmpl = entities.get v["tmpl"].as(String)
      max = v["max"].as(Int64).to_i
      @definitions << Definition.new @definitions.size, klass, tmpl, max
    end
    @instances = Array(Instance).new(@definitions.size) { Instance.new }
  end

  def available_agent?(klass)
    d = find_definition klass
    if d
      i = @instances[d.index]
      d.max > i.count
    else
      false
    end
  end

  def request_agent(klass, owner, world)
    d = find_definition klass
    if d
      i = @instances[d.index]
      e = i.request_agent d, owner, world
      e.query klass, &.home=(owner) if e
      e
    else
      nil
    end
  end

  requires entity.any? &.includes?(entity)
  def return_agent(entity)
    d = find_definition entity.template
    if d
      i = @instances[d.index]
      i.return_agent d, entity
    end
  end

  def find_definition(tmpl : EntityTemplate)
    @definitions.find { |d| d.agent == tmpl }
  end

  def find_definition(klass)
    @definitions.find { |d| d.component == klass }
  end
end
