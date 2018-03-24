class Map
  struct ObjSerializer
    def marshal(obj, node)
      node.marshal "size", obj.size
    end

    def unmarshal(node)
      size = node.unmarshal "size", Boleite::Vector2i
      map = Map.new size
      map
    end

    def write_terrain_list(world, io)
      terrain_list = [""] of String
      world.terrains.each_type do |key, terrain|
        terrain_list << key unless terrain_list.includes? key
      end
      io.write_bytes terrain_list.size.to_i8
      terrain_list.each do |str|
        io.write_bytes str.bytesize
        io.write str.to_slice
      end
      terrain_list
    end

    def write_map_data(data, terrains, io)
      data.each do |point|
        terrain_index = 0u8
        if terrain = point.terrain
          index = terrains.index terrain.key
          terrain_index = index.to_u8 if index
        end
        io.write_bytes terrain_index
        io.write_bytes point.height
      end
    end

    def read_terrain_list(io)
      num_types = io.read_bytes UInt8
      Array(String).new num_types do
        len = io.read_bytes Int32
        String.build(len) { |str| IO.copy io, str, len }
      end
    end

    def read_map_data(io)
      map_data = [] of {UInt8, Float32}
      begin
        while true
          terrain = io.read_bytes UInt8
          height = io.read_bytes Float32
          map_data << {terrain, height}
        end
      rescue IO::EOFError
        map_data
      end
    end
  end

  extend Boleite::Serializable(ObjSerializer)
end