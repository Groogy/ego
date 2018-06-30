struct EntityGraphicsTemplate
  struct ObjSerializer
    def unmarshal(node)
      uv = node.unmarshal "uv", Boleite::Vector2u
      uv_size = node.unmarshal "uv_size", Boleite::Vector2u
      height = node.unmarshal_int "height"
      EntityGraphicsTemplate.new uv, uv_size, height.to_u16
    end
  end

  extend Boleite::Serializable(ObjSerializer)
end