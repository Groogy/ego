class WorldGenerator
  @available_myths = [] of MythTemplate
  @myths = [] of Myth

  getter world, deity

  def initialize(size)
    @world = World.new size
    @world.load_data
    @world.simulation = WorldGenerationSimulation.new

    @deity = Deity.new

    find_available_myths
  end

  def update
    @world.simulation.update @world
  end

  def each_available_myth
    @available_myths.each do |m|
      yield m
    end
  end

  def select_myth(template)
    @myths << Myth.new template
    @myths.last.apply @world, @deity
    find_available_myths
  end

  def find_available_myths
    templates = @world.myth_templates
    if @myths.empty?
      @available_myths = templates.get_all_of MythTemplate::Type::CreationStart
    else
      @available_myths = templates.find_valid_for @myths
    end
  end

  def create_story
    @myths.join ", " { |m| m.template.generate_text @world, @deity }
  end
end