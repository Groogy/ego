class EntityCategory
  struct ObjSerializer
    def unmarshal(node)
      id = node.key.as(String)
      name = node.unmarshal_string "name"
      EntityCategory.new id, name
    end
  end

  extend Boleite::Serializable(ObjSerializer)
end