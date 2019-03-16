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

class GeneratorFillWorldMythEffect < MythEffect
  def apply(world, deity)
    map = world.map.terrain
    terrain = world.terrains.find @arg
    map.fill_with terrain
  end
end

class GeneratorCreateHeightsMythEffect < MythEffect
  def apply(world, deity)
    map = world.map.heightmap
    size = map.size
    scale = calculate_scale size
    perlin = PerlinNoise.new world.random.get_int
    size.y.times do |y|
      size.x.times do |x|
        val = generate_height perlin, x, y, scale
        map.set_height x, y, val.to_f32
      end
    end
  end

  def calculate_scale(size)
    (size.x + size.y).to_f / 2 * Defines.generator_noise_scale
  end

  def generate_height(perlin, x, y, scale)
    val = perlin.noise x.to_f / scale, y.to_f / scale, 0.0
    val = val * 2 - 1
    val * @arg.to_f
  end

  invariant Defines.generator_noise_scale > 0.0
end