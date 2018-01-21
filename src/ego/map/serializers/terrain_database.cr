class TerrainDatabase
  class Collection < Hash(String, TerrainType)
    struct ObjSerializer
      def unmarshal(node)
        result = Collection.new
        node.each do |key, value|
          key = key.as(String)
          terrain = node.unmarshal key, TerrainType
          terrain.key = key
          result[key] = terrain
        end
        result
      end
    end

    extend Boleite::Serializable(ObjSerializer)
  end
end