class EntityManager
  struct Serializer
    def marshal(obj, node)
      node.marshal "next_id", obj.id_generator.peak_next
      node.marshal "num", obj.entities.size
      node.marshal "instances", obj.entities
    end

    def unmarshal(node)
      world = node.data
      id_generator = EntityIdGenerator.new node.unmarshal_int("next_id")
      manager = EntityManager.new world.map, id_generator
      pre_load_entities node, manager
      load_position_references manager
      load_entities node, manager, world
      manager
    end

    def pre_load_entities(node, manager)
      entities_pre = node.unmarshal "instances", Array(EntityPreLoadData)
      entities_pre.each do |data|
        entity = Entity.new data.id, data.template, data.pos
        manager.add entity
      end
    end

    def load_position_references(manager)
      manager.each do |entity|
        pos = entity.position
        if pos.is_a? LoadingOffmapEntityPos
          entity.position = pos.create_pos manager
        end
      end
    end

    def load_entities(node, manager, world)
      entities = node.value.as(Hash(Boleite::Serializer::Type, Boleite::Serializer::Type))["instances"]
      manager.each_with_index do |entity, index|
        data = { entity, world, manager }
        child = Boleite::Serializer::Node.new data, entities, index
        child.unmarshal index, Entity
      end
    end
  end

  extend Boleite::Serializable(Serializer)
end