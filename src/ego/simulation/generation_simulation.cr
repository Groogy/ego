abstract class WorldSimulation
end

class WorldGenerationSimulation < WorldSimulation
  property average_temperature, temperature_volatility
  property water_level, max_height, fertility

  def initialize
    @average_temperature = Defines.generator_start_average_temperature
    @temperature_volatility = Defines.generator_start_temperature_volatility
    @water_level = Defines.generator_start_water_level
    @max_height = Defines.generator_start_max_height
    @fertility = Defines.generator_start_fertility
  end
end