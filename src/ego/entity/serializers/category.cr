class EntityCategory
  struct ObjSerializer
    def unmarshal(node)
      id = node.key.as(String)
      name = node.unmarshal_string "name"
      visible = node.unmarshal_bool? "visible", false
      EntityCategory.new id, name, visible
    end
  end

  extend Boleite::Serializable(ObjSerializer)
end