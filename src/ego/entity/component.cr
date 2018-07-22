abstract class EntityComponent
  @data : EntityComponentData

  struct NullSerializer
    def marshal(obj, node)
    end

    def unmarshal(obj, node)
    end
  end

  def self.find_class(id)
    {% for klass in @type.all_subclasses %}
      {% unless klass.abstract? %}
    return {{ klass }} if {{ klass }}.id == id
      {% end %}
    {% end %}
  end

  def self.initialize_obj(obj, data, entity, world)
    obj.initialize data, entity, world
  end

  def self.id
    id = to_s
    id[0, id.size - "Component".size].underscore
  end

  def initialize(@data, entity, world)
  end

  def id
    self.class.id
  end

  def self.component_serializer
    NullSerializer.new
  end
end
