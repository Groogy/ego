class FruitingComponent
  struct Serializer
    def marshal(obj, node)
      obj = obj.as(FruitingComponent)
      node.marshal "time_since_growth", obj.time_since_growth
    end

    def unmarshal(obj, node)
      obj = obj.as(FruitingComponent)
      obj.time_since_growth = node.unmarshal "time_since_growth", GameTime
    end
  end

  def self.component_serializer
    Serializer.new
  end
end