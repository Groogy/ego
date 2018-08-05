class NameGeneratorManager
  struct Serializer
    def marshal(obj, node)
      node.marshal "history", obj.history
    end

    def unmarshal(node)
      obj = NameGeneratorManager.new
      obj.history = node.unmarshal "history", Array(String)
      obj
    end
  end

  extend Boleite::Serializable(Serializer)
end