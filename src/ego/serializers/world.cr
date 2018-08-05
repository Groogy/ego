class World
  struct Serializer
    def marshal(obj, node)
      node.marshal "date", obj.current_tick
      node.marshal "random", obj.random
      node.marshal "map", obj.map
      node.marshal "entities", obj.entities
      node.marshal "social_units", obj.social_units
      node.marshal "name_generators", obj.name_generators
    end

    def unmarshal(node)
      world = node.data
      # Loads the history
      world.name_generators = node.unmarshal "name_generators", NameGeneratorManager
      world.load_data
      world.current_tick = node.unmarshal "date", GameTime
      world.random = node.unmarshal "random", Boleite::NoiseRandom
      world.map = node.unmarshal "map", Map
      world.entities = node.unmarshal "entities", EntityManager
      world.social_units = node.unmarshal "social_units", SocialUnitManager
      world
    end
  end

  extend Boleite::Serializable(Serializer)
end