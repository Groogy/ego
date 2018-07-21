struct EntityGraphicsTemplate
  struct ObjSerializer
    def unmarshal(node)
      uv = node.unmarshal "uv", Boleite::Vector2u
      EntityGraphicsTemplate.new uv
    end
  end

  extend Boleite::Serializable(ObjSerializer)
end