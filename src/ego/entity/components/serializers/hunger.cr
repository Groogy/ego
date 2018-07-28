class HungerComponent
  struct Serializer
    def marshal(obj, node)
      obj = obj.as(HungerComponent)
      node.marshal "satisfaction", obj.satisfaction
    end

    def unmarshal(obj, node)
      obj = obj.as(HungerComponent)
      obj.satisfaction = node.unmarshal_int "satisfaction"
    end
  end

  def self.component_serializer
    Serializer.new
  end
end