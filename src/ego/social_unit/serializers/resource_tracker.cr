class SocialUnitResourceTracker
  struct Serializer
    def marshal(obj, node)
      node.marshal "areas", obj.areas
    end

    def unmarshal(node)
      tracker = SocialUnitResourceTracker.new
      tracker.areas = node.unmarshal "areas", Array(Area)
      tracker
    end
  end

  extend Boleite::Serializable(Serializer)

  class Area
    struct Serializer
      def marshal(obj, node)
        node.marshal "resource", obj.resource.id
        node.marshal "tiles", obj.tiles
        node.marshal "quantity", obj.quantity
        node.marshal "last_prospect", obj.last_prospect
      end
  
      def unmarshal(node)
        world = node.data[1]
        resource_key = node.unmarshal_string "resource"
        resource = world.entity_templates.get resource_key
        tiles = node.unmarshal "tiles", Array(Map::Pos)
        quantity = node.unmarshal_int "quantity"
        last_prospect = node.unmarshal "last_prospect", GameTime

        Area.new resource, tiles, quantity.to_i32, last_prospect
      end
    end
  
    extend Boleite::Serializable(Serializer)
  end
end