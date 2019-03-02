class World
  @map : Map
  @terrains = TerrainDatabase.new
  @myth_templates = MythTemplateManager.new
  @name_generators = NameGeneratorManager.new
  @tectonics = TectonicsEngine.new
  @current_tick = GameTime.new
  @paused = false
  @random : Boleite::Random

  getter current_tick, random, terrains, map
  getter myth_templates
  getter name_generators
  getter tectonics
  getter? paused

  protected setter current_tick, random, name_generators

  def initialize(size : Boleite::Vector2u)
    @random = Boleite::NoiseRandom.new 0u32
    @map = Map.new size
  end

  def load_data
    @terrains.load_folder "data/tiles"
    @myth_templates.load_folder "data/myths"
    @name_generators.load_folder "data/names"
  end

  def toggle_pause
    @paused = !@paused
  end

  def date
    @current_tick
  end

  def update
    unless @paused
      @current_tick = @current_tick.next_tick
    end
  end

  def render(renderer)
  end
end