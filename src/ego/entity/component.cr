class EntityComponent
  @data : EntityComponentData

  def self.find_class(id)
    {% for klass in @type.subclasses %}
    return {{ klass }} if {{ klass }}.id == id
    {% end %}
  end

  def self.initialize_obj(obj, data, entity, world)
    obj.initialize data, entity, world
  end

  def self.id
    id = to_s
    id[0, id.size - "Component".size].downcase
  end

  def initialize(@data, entity, world)
  end
end
