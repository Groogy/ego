class World
  struct Serializer
    def marshal(obj, node)
      node.marshal "date", obj.current_tick
      node.marshal "random", obj.random
      node.marshal "map", obj.map
      node.marshal "entities", obj.entities
    end

    def unmarshal(node)
      world = node.data
      world.load_data
      world.current_tick = node.unmarshal "date", GameTime
      world.random = node.unmarshal "random", Boleite::NoiseRandom
      world.map = node.unmarshal "map", Map
      world.entities = node.unmarshal "entities", EntityManager
      world
    end
  end

  extend Boleite::Serializable(Serializer)
end