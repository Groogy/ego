class SocialUnit
  struct Serializer
    def marshal(obj, node)
      node.marshal "id", obj.id
    end

    def unmarshal(node)
      instance = node.data[0] # We've preloaded some data
      world = node.data[1]
      assert instance.id == node.unmarshal_int "id"
      instance
    end
  end

  extend Boleite::Serializable(Serializer)
end