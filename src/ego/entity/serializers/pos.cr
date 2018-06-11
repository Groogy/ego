struct EntityPos
  struct Serializer
    def marshal(obj, node)
      node.marshal "on_map", obj.on_map?
      if obj.on_map?
        point = Boleite::Vector2u16.new obj.point.x, obj.point.y
        node.marshal "point", point
      else
        parent = obj.parent
        assert parent
        node.marshal "parent", parent.id if parent
      end
    end

    def unmarshal(node)
      on_map = node.unmarshal_bool "on_map"
      if on_map
        MapEntityPos.new node.unmarshal("point", Boleite::Vector2u16)
      else
        LoadingOffmapEntityPos.new node.unmarshal_int("parent")
      end
    end
  end

  extend Boleite::Serializable(Serializer)
end