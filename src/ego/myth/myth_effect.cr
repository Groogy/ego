abstract class MythEffect
  include CrystalClear

  Contracts.ignore_method initialize

  def self.find_class(id)
    {% for klass in @type.all_subclasses %}
      {% unless klass.abstract? %}
    return {{ klass }} if {{ klass }}.id == id
      {% end %}
    {% end %}
  end

  def self.id
    id = to_s
    id[0, id.size - "MythEffect".size].underscore
  end
  
  def initialize(@arg : String)
  end

  abstract def apply(world, deity)
end

class SetGenderMythEffect < MythEffect
  def apply(world, deity)
    gender = Deity::Gender.parse @arg.camelcase
    deity.gender = gender
  end
end

abstract class GeneratorMythEffect < MythEffect
  private def get_simulation(world)
    world.simulation.as(WorldGenerationSimulation)
  end
end

class GeneratorChangeAverageTemperatureMythEffect < GeneratorMythEffect
  def apply(world, deity)
    val = @arg.to_f
    simulation = get_simulation world
    simulation.average_temperature += val
  end
end

class GeneratorChangeTemperatureVolatilityMythEffect < GeneratorMythEffect
  def apply(world, deity)
    val = @arg.to_f
    simulation = get_simulation world
    simulation.temperature_volatility += val
  end
end

class GeneratorChangeWaterLevelMythEffect < GeneratorMythEffect
  def apply(world, deity)
    val = @arg.to_f
    simulation = get_simulation world
    simulation.water_level += val
  end
end

class GeneratorChangeMaxHeightMythEffect < GeneratorMythEffect
  def apply(world, deity)
    val = @arg.to_f
    simulation = get_simulation world
    simulation.max_height += val
  end
end

class GeneratorChangeFertilityMythEffect < GeneratorMythEffect
  def apply(world, deity)
    val = @arg.to_f
    simulation = get_simulation world
    simulation.fertility += val
  end
end

class GeneratorStartSimulationMythEffect < GeneratorMythEffect
  def apply(world, deity)
    simulation = get_simulation world
    simulation.start_simulation
  end
end
