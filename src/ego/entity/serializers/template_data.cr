struct EntityTemplateData
  struct ObjSerializer
    def unmarshal(node)
      result = EntityTemplateData.new node.key.as(String)
      result.name = node.unmarshal_string "name"
      result.categories = node.unmarshal "categories", Array(String)
      result
    end
  end

  extend Boleite::Serializable(ObjSerializer)
end