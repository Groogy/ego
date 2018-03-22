class World
  struct Serializer
    def marshal(obj, node)
      node.marshal "date", obj.current_tick
      node.marshal "map", obj.map
    end

    def unmarshal(node)
      world = World.new
      world.current_tick = node.unmarshal "date", GameTime
      world.map = node.unmarshal "map", Map
      world
    end
  end

  extend Boleite::Serializable(Serializer)
end