struct GameTime
  struct Serializer
    def marshal(obj, node)
      node.marshal "ticks", obj.to_i
    end

    def unmarshal(node)
      hsh = {} of String => Int64
      node.each do |key, value|
        hsh[key.as(String)] = value.as(Int64)
      end
      GameTime.new hsh
    end
  end

  extend Boleite::Serializable(Serializer)
end