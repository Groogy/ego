class MythTemplateData
  struct ObjSerializer
    def unmarshal(node)
      id = node.key.as(String)
      type = unmarshal_type node
      result = MythTemplateData.new id, type
      result.text = node.unmarshal_string "text"
      if node.has? "follows"
        result.follows = node.unmarshal "follows", Array(String)
      end
      result
    end

    def unmarshal_type(node)
      str = node.unmarshal_string "type"
      MythTemplate::Type.parse str.camelcase
    end
  end

  extend Boleite::Serializable(ObjSerializer)
end
