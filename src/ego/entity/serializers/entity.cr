class Entity
  struct Serializer
    def marshal(obj, node)
      node.marshal "id", obj.id
      node.marshal "tmpl", obj.template.id
      node.marshal "pos", obj.position
    end

    def unmarshal(node)
      entity = node.data # We've preloaded some data
      assert entity.id == node.unmarshal_int "id"
      entity
    end
  end

  extend Boleite::Serializable(Serializer)
end