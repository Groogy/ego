abstract class AgentBaseComponent
  struct Serializer
    def marshal(obj, node)
      obj = obj.as(AgentBaseComponent)
      if home = obj.home
        node.marshal "home", home.id
      end
      if task = obj.task
        node.marshal "task", task
      end
    end

    def unmarshal(obj, node)
      world = node.data[1]
      entities = node.data[2]
      obj = obj.as(AgentBaseComponent)
      if node.has? "home"
        id = node.unmarshal_int "home"
        obj.home = entities.find_by_id id
      end
      if node.has? "task"
        unmarshal_task obj, node
      end
      obj
    end

    def unmarshal_task(obj, node)
      data = node.value.as(Hash(Boleite::Serializer::Type, Boleite::Serializer::Type))["task"]
      child = Boleite::Serializer::Node.new node.data, data, "task"
      klass_id = child.unmarshal_string "type"
      klass = AgentTask.find_class klass_id
      if klass
        task = klass.serializer.unmarshal child
        obj.load_task task
      else
        raise "Unknown class for AgentTask!"
      end
    end
  end

  def self.component_serializer
    Serializer.new
  end
end

abstract class AgentTask
  abstract struct BaseSerializer
    def marshal(obj, node)
      node.marshal "type", obj.class.to_s
    end

    def unmarshal(node, klass, *args)
      klass.new *args
    end
  end
end

class GoHomeTask < AgentTask
  struct Serializer < BaseSerializer
    def marshal(obj, node)
      super obj, node
      obj = obj.as(GoHomeTask)
      node.marshal "home", obj.home.id
    end

    def unmarshal(node)
      world = node.data[1]
      home_id = node.unmarshal_int "home"
      home = world.entities.find_by_id home_id
      if home
        unmarshal node, GoHomeTask, home
      else
        raise "Failed to find entity(#{home_id}) for GoHomeTask."
      end
    end
  end

  extend Boleite::Serializable(Serializer)
end