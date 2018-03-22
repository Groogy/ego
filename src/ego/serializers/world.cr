class World
  struct Serializer
    def marshal(obj, node)
      node.marshal "date", obj.current_tick
    end

    def unmarshal(node)
      world = World.new
      world.current_tick = node.unmarshal "date", GameTime
      pp world.current_tick
      world
    end
  end

  extend Boleite::Serializable(Serializer)
end