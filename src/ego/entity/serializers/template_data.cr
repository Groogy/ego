class EntityTemplateData
  struct ObjSerializer
    def unmarshal(node)
      result = EntityTemplateData.new node.key.as(String)
      result.name = node.unmarshal_string "name"
      result.description = node.unmarshal_string "description" if node.has_key? "description"
      result.size = node.unmarshal "size", Boleite::Vector2i
      result.categories = node.unmarshal "categories", Array(String)
      result.graphics = node.unmarshal "graphics", EntityGraphicsTemplate
      result.components = node.unmarshal "components", Array(EntityComponentData)
      result
    end
  end

  extend Boleite::Serializable(ObjSerializer)
end
