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

  class FillTerrainStage < Stage
    include CrystalClear
    
    DIRECTIONS = {
      Boleite::Vector2i.new(-1,  0), Boleite::Vector2i.new( 1, 0),
      Boleite::Vector2i.new( 0, -1), Boleite::Vector2i.new( 0, 1),
    }
    @queue = Deque(Boleite::Vector2i).new
    @random = Boleite::NoiseRandom.new 0u32
    @pixels_covered = 0u32

    ensures @pixels_covered <= world.map.size.x * world.map.size.y
    def update(world : World, simulation : WorldGenerationSimulation)
      map = world.map.terrain
      default = world.terrains.find Defines.generator_start_terrain
      if @pixels_covered > world.map.size.x * world.map.size.y * 0.9999
        fast_fill map, default
      else
        partial_fill map, default
      end
    end

    private def fast_fill(map, default)
      map.size.y.times do |y|
        map.size.x.times do |x|
          unless map.get_terrain? x, y
            map.set_terrain Boleite::Vector2u.new(x, y), default
            @pixels_covered += 1
          end
        end
      end
    end

    private def partial_fill(map, default)
      @queue.clear
      pos = find_start_pos map
      map[pos] = default
      @pixels_covered += 1
      @queue << pos
      count = 0
      while !@queue.empty?
        pos = @queue.shift
        count += 1
        DIRECTIONS.each do |dir|
          n = pos + dir
          if map.inside?(n) && map.empty_terrain?(n)
            map[n] = default
            @pixels_covered += 1
            @queue << n
          end
        end
        break if count > 50000
      end
    end
    
    def done?(world : World)
      @pixels_covered >= world.map.size.x * world.map.size.y
    end

    def on_done
      octaves = Defines.generator_octaves
      amplitude = Defines.generator_start_amplitude
      frequency = Defines.generator_start_frequency
      GenerateLandmassStage.new amplitude, frequency, octaves.to_u8
    end

    def find_start_pos(map)
      pos = map.size.to_i / 2
      while map[pos]?
        pos.x = (@random.get_int 0, map.size.x).to_i
        pos.y = (@random.get_int 0, map.size.y).to_i
      end
      pos
    end
  end

  class GenerateLandmassStage < Stage
    include CrystalClear

    FACTOR_INC = 0.01

    @factor = 0.0

    @heightmap : Array(Float32)?

    def initialize(@amplitude : Float64, @frequency : Float64, @iterations : UInt8)
    end

    def update(world : World, simulation : WorldGenerationSimulation)
      target = world.map.heightmap
      if heightmap = @heightmap
        apply_heightmap heightmap, target
        @factor = {1.0, @factor + FACTOR_INC}.min
      else
        @heightmap = generate_heightmap target.size, world.random, simulation
      end
    end

    private def apply_heightmap(heightmap, target)
      target.map_with_index! do |v,i|
        v + heightmap[i] * FACTOR_INC
      end
    end

    private def generate_heightmap(size, random, simulation)
      scale = (size.x + size.y).to_f / 2 * Defines.generator_noise_scale
      perlin = PerlinNoise.new random.get_int
      Array(Float32).new size.x * size.y do |i|
        x = i % size.x
        y = (i - x) / size.x
        x = x.to_f / scale * @frequency
        y = y.to_f / scale * @frequency
        val = perlin.noise x, y, 0.0
        val = val * 2 - 1
        val *= @amplitude
        (val * simulation.max_height).to_f32
      end
    end

    def done?(world : World)
      @factor >= 1.0
    end

    def on_done
      if @iterations > 0
        persistance = Defines.generator_persistance
        lacunarity = Defines.generator_lacunarity
        GenerateLandmassStage.new @amplitude * persistance, @frequency * lacunarity, @iterations - 1
      else
        GenerateRainStage.new
      end
    end

    invariant Defines.generator_noise_scale > 0.0
  end

  class GenerateRainStage < Stage
    FACTOR_INC = 0.001
    
    @factor = 0.0

    def update(world : World, simulation : WorldGenerationSimulation)
      @factor += FACTOR_INC
      world.map.water_level = simulation.water_level * @factor
    end

    def on_done
      GenerateHeatStage.new
    end

    def done?(world : World)
      @factor >= 1.0
    end
  end

  class GenerateHeatStage < Stage
    TARGET = 10

    @iterations = 0

    def update(world : World, simulation : WorldGenerationSimulation)
      if @iterations == 0
        fill_with_heat world, simulation
      else
        generate_volatile_heat world.map, world.random, simulation
      end
      @iterations += 1
    end

    def fill_with_heat(world, simulation)
      heatmap = world.map.heatmap
      heightmap = world.map.heightmap
      water_level = world.map.water_level
      pos = Boleite::Vector2u.zero
      mid_point = heatmap.size.y / 2.0
      average_temprature = simulation.average_temperature
      heatmap.size.y.times do |y|
        pos.y = y
        dist = (y - mid_point).abs.to_f / mid_point
        heat = average_temprature * (Defines.heat_temperature_coverage - dist)
        heatmap.size.x.times do |x|
          pos.x = x
          height = heightmap.get_height pos
          over_water = {height - water_level, 0.0}.max
          height_effect = Defines.heat_height_loss * over_water
          heatmap[pos] = heat.to_f32 - height_effect
        end
      end
    end

    def generate_volatile_heat(map, random, simulation)
      size = map.size
      heatmap = map.heatmap
      scale = (size.x + size.y).to_f / 2 * Defines.generator_noise_scale
      perlin = PerlinNoise.new random.get_int
      (size.x * size.y).times do |i|
        x = i % size.x
        y = (i - x) / size.x
        x = x.to_f / scale
        y = y.to_f / scale
        val = perlin.noise x, y, 0.0
        val = val * 2 - 1
        heatmap[i.to_i] += val * simulation.temperature_volatility
      end
    end

    def done?(world : World)
      @iterations >= TARGET
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
