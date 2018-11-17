class Map
  struct Pos
    struct Serializer
      def marshal(obj, node)
        node.value = [obj.x.to_i64, obj.y.to_i64] of Boleite::Serializer::Type
      end
  
      def unmarshal(node)
        x = node.unmarshal_int 0
        y = node.unmarshal_int 1
        Pos.new x.to_i16, y.to_i16
      end
    end
    extend Boleite::Serializable(Serializer)
  end
end