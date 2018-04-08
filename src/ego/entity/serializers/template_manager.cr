class EntityTemplateManager
  class LoadedData < Hash(String, EntityTemplateData)
    struct ObjSerializer
      def unmarshal(node)
        result = LoadedData.new
        node.each do |key, value|
          key = key.as(String)
          template = node.unmarshal key, EntityTemplateData
          result[key] = template
        end
        result
      end
    end

    extend Boleite::Serializable(ObjSerializer)
  end
end