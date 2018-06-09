class World
  struct Serializer
    def marshal(obj, node)
      node.marshal "date", obj.current_tick
      node.marshal "random", obj.random
      node.marshal "map", obj.map
    end

    def unmarshal(node)
      world = World.new
      world.load_data
      world.current_tick = node.unmarshal "date", GameTime
      world.random = node.unmarshal "random", Boleite::NoiseRandom
      world.map = node.unmarshal "map", Map
      world
    end
  end

  extend Boleite::Serializable(Serializer)
end