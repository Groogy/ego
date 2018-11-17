class Path
  struct Serializer
    def marshal(obj, node)
      node.marshal "step", obj.step
      node.marshal "points", obj.points
    end

    def unmarshal(node)
      points = node.unmarshal "points", Array(Map::Pos)
      step = node.unmarshal_int "step"
      Path.new points, step.to_i32
    end
  end

  extend Boleite::Serializable(Serializer)
end