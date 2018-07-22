class Entity
  struct Serializer
    def marshal(obj, node)
      node.marshal "id", obj.id
      node.marshal "tmpl", obj.template.id
      node.marshal "pos", obj.position
      node.marshal "components", obj.components
    end

    def unmarshal(node)
      entity = node.data[0] # We've preloaded some data
      world = node.data[1]
      assert entity.id == node.unmarshal_int "id"
      preload_components node, entity, world
      load_components node, entity
      entity
    end

    def preload_components(node, entity, world)
      entity.components = node.unmarshal "components", Array(EntityComponent)
      entity.components.each_with_index do |c, i|
        data = entity.template.get_component_data i
        EntityComponent.initialize_obj c, data, entity, world
      end
    end

    def load_components(node, entity)
      data = node.value.as(Hash(Boleite::Serializer::Type, Boleite::Serializer::Type))["components"]
      data = data.as(Array(Boleite::Serializer::Type))
      entity.components.each_with_index do |c, i|
        child = Boleite::Serializer::Node.new node.data, data[i], i
        assert c.id == child.unmarshal_string "id"
        c.class.component_serializer.unmarshal c, child
      end
    end
  end

  extend Boleite::Serializable(Serializer)
end