class EntityComponentData
  struct ObjSerializer
    def unmarshal(node)
      id = node.unmarshal_string "id"
      raw_data = node.unmarshal "args", Hash(String, Boleite::Serializer::Type)
      data = convert_args_hash raw_data
      result = EntityComponentData.new id, data
      result
    end

    def convert_args_hash(args) : Hash(String, DataType)
      hsh = {} of String => DataType
      args.map do |key, val|
        hsh[key.to_s] = case val
        when Hash(Boleite::Serializer::Type, Boleite::Serializer::Type)
          convert_args_hash val
        when Array(Boleite::Serializer::Type)
          convert_args_array val
        else
          val.as(DataType)
        end
      end
      hsh
    end

    def convert_args_array(args) : Array(DataType)
      arr = [] of DataType
      args.each do |val|
        arr << case val
        when Hash(Boleite::Serializer::Type, Boleite::Serializer::Type)
          convert_args_hash val
        when Array(Boleite::Serializer::Type)
          convert_args_array val
        else
          val.as(DataType)
        end
      end
      arr
    end
  end

  extend Boleite::Serializable(ObjSerializer)
end