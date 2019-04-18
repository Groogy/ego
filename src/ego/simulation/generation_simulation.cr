abstract class WorldSimulation
end

class WorldGenerationSimulation < WorldSimulation
  property average_temperature, temperature_volatility
  property water_level, max_height, fertility

  abstract class Stage
    abstract def update(world : World, simulation : WorldGenerationSimulation) : Nil
    abstract def done?(world : World) : Bool

    def on_done
      NullStage.new
    end
  end

  class NullStage < Stage
    def update(world : World, simulation : WorldGenerationSimulation)
      # Do nothing
    end

    def done?(world : World)
      false
    end
  end

  @stage : Stage = NullStage.new

  def initialize
    @average_temperature = Defines.generator_start_average_temperature
    @temperature_volatility = Defines.generator_start_temperature_volatility
    @water_level = Defines.generator_start_water_level
    @max_height = Defines.generator_start_max_height
    @fertility = Defines.generator_start_fertility
  end

  def start_simulation
    @stage = FillTerrainStage.new
  end

  def update(world)
    if @stage.done? world
      @stage = @stage.on_done
    else
      @stage.update world, self
    end
  end

  def render(renderer)
  end
end
