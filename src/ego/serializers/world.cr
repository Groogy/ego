class World
  struct Serializer
    def marshal(obj, node)
      node.marshal "date", obj.current_tick
      node.marshal "random", obj.random
      node.marshal "name_generators", obj.name_generators
    end

    def unmarshal(node)
      world = node.data
      # Loads the history
      world.name_generators = node.unmarshal "name_generators", NameGeneratorManager
      world.load_data
      world.current_tick = node.unmarshal "date", GameTime
      world.random = node.unmarshal "random", Boleite::NoiseRandom
      world
    end
  end

  extend Boleite::Serializable(Serializer)
end