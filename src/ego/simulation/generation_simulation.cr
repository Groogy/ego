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
      GenerateLandmassStage.new 0.25
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

    FACTOR_INC = 0.005

    @factor = 0.0
    @heightmap : Array(Float32)?

    def initialize(@height_mod = 1.0)
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
        val = perlin.noise x.to_f / scale, y.to_f / scale, 0.0
        val = val * 2 - 1
        (val * simulation.max_height * @height_mod).to_f32
      end
    end

    def done?(world : World)
      @factor >= 1.0
    end

    invariant Defines.generator_noise_scale > 0.0
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
end