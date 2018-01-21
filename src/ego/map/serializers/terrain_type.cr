class TerrainType
  struct ObjSerializer
    def unmarshal(node)
      result = TerrainType.new
      result.name = node.unmarshal_string "name"
      result.color = node.unmarshal "color", Boleite::Colorf
      result
    end
  end

  extend Boleite::Serializable(ObjSerializer)
end