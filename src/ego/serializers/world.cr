class World
  struct Serializer
    def marshal(obj, node)

      node.marshal("backend", obj.backend)
    end

    def unmarshal(node)
      world = World.new
      world
    end
  end

  extend Boleite::Serializable(Serializer)
end