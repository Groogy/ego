class PopulationComponent
  struct Serializer
    def marshal(obj, node)
      obj = obj.as(PopulationComponent)
      node.marshal "population", obj.population
      node.marshal "growth", obj.growth
    end

    def unmarshal(obj, node)
      obj = obj.as(PopulationComponent)
      obj.population = node.unmarshal_int "population"
      obj.growth = node.unmarshal "growth", GameTime
    end
  end

  def self.component_serializer
    Serializer.new
  end
end
