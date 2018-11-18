class MovingComponent
  struct Serializer
    def marshal(obj, node)
      obj = obj.as(MovingComponent)
      if target = obj.target
        node.marshal "target", target
        node.marshal "progress", obj.progress 
      end
    end

    def unmarshal(obj, node)
      obj = obj.as(MovingComponent)
      if node.has? "target"
        obj.target = node.unmarshal "target", Path
        obj.progress = node.unmarshal_float "progress"
      end
    end
  end

  def self.component_serializer
    Serializer.new
  end
end