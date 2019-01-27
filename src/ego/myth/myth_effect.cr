abstract class MythEffect
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
    map = world.map
    terrain = world.terrains.find @arg
    map.each_tile do |pos, data|
      map.set_terrain pos, terrain
    end
  end
end