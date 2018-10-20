abstract class AgentBaseComponent
  struct Serializer
    def marshal(obj, node)
      obj = obj.as(AgentBaseComponent)
      if home = obj.home
        node.marshal "home", home.id
      end
    end

    def unmarshal(obj, node)
      world = node.data[1]
      entities = node.data[2]
      obj = obj.as(AgentBaseComponent)
      id = node.unmarshal_int "home"
      obj.home = entities.find_by_id id
      obj
    end
  end

  def self.component_serializer
    Serializer.new
  end
end