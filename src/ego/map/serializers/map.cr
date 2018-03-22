class Map
  struct ObjSerializer
    def marshal(obj, node)
      terrain_list = build_terrain_list node.data
      node.marshal "size", obj.size
      node.marshal "type_list", terrain_list
    end

    def unmarshal(node)
      size = node.unmarshal "size", Boleite::Vector2i
      map = Map.new size
      map
    end

    def build_terrain_list(world)
      terrain_list = [] of String
      world.terrain_types.each_type do |key, terrain|
        terrain_list << key unless terrain_list.includes? key
      end
      terrain_list
    end
  end

  extend Boleite::Serializable(ObjSerializer)
end