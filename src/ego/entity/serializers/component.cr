class EntityComponent
  struct Serializer
    def marshal(obj, node)
      node.marshal "id", obj.id
      obj.class.component_serializer.marshal obj, node
    end

    def unmarshal(node)
      id = node.unmarshal_string "id"
      klass = EntityComponent.find_class id
      if klass
        entity = node.data[0]
        world = node.data[1]
        data = entity.template.get_component_data id
        obj = klass.allocate
      else
        raise "Unknown entity component when reading serialized data: `#{id}`"
      end
    end
  end

  extend Boleite::Serializable(Serializer)
end
