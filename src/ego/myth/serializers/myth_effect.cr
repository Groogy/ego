abstract class MythEffect
  struct ObjSerializer
    def unmarshal(node)
      id = node.key.as(String)
      klass = MythEffect.find_class id
      if klass
        effect = klass.new node.value.to_s
      else
        raise "Unknown myth effect when reading serialized data: `#{id}`"
      end
    end
  end

  extend Boleite::Serializable(ObjSerializer)
end
