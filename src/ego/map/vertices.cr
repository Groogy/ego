class MapRenderer
  struct Vertices
    struct Vertex < Boleite::Vertex
      @pos : Boleite::Vector4f32
      @color : Boleite::Vector4f32
  
      getter pos, color
  
      def initialize(pos, @color)
        @pos = Boleite::Vector4f32.new(pos)
      end
    end

    property need_update, vbo

    @need_update = true
    @vbo : Boleite::VertexBufferObject?

    def get_vertices(map, gfx) : Boleite::VertexBufferObject
      vbo = @vbo
      if vbo.nil?
        vbo = create_vbo gfx
        @vbo = vbo
      end
      if @need_update
        update_vbo map, vbo 
        @need_update = false
      end
      vbo
    end
  
    private def create_vbo(gfx) : Boleite::VertexBufferObject
      layout = Boleite::VertexLayout.new [
        Boleite::VertexAttribute.new(0, 4, :float, 32u32, 0u32,  0u32),
        Boleite::VertexAttribute.new(0, 4, :float, 32u32, 16u32, 0u32)
      ]
      vbo = gfx.create_vertex_buffer_object
      vbo.layout = layout
      vbo.primitive = Boleite::Primitive::TrianglesStrip
      vbo.create_buffer
      vbo.create_buffer
      vbo.set_indices 1
      vbo
    end
  
    private def update_vbo(map, vbo)
      vertices = vbo.get_buffer 0
      vertices.clear
      create_vertices map, vertices
      indices = vbo.get_buffer 1
      indices.clear
      create_indices map, indices
    end

    private def create_vertices(map, buffer)
      size = map.size
      size.y.times do |y|
        size.x.times do |x|
          height = map.get_height x, y
          terrain = map.get_terrain x, y
          vertex = Vertex.new(
            [x.to_f32, height.to_f32, y.to_f32, 1f32], 
            get_vertex_color(terrain)
          )
          buffer.add_data vertex
        end
      end
    end

    private def create_indices(map, buffer)
      size = map.size
      create_first_indices size, buffer
      x = 0
      y = 1

      while x+2 < size.x
        create_column_indices x, y, size, buffer
        create_transfer_indices(x+1, size.y-1, size, buffer)
        create_column_indices_backwards x+1, size.y-2, size, buffer
        if x + 3 > size.x
          create_transfer_indices_backwards x+2, 0, size, buffer
        end
        x += 2
        y = 0
      end
    end

    private def create_first_indices(size, buffer)
      index1 = 0 + 0 * size.x
      index2 = 1 + 0 * size.x
      index3 = 0 + 1 * size.x
      buffer.add_data index1
      buffer.add_data index2
      buffer.add_data index3
    end

    private def create_transfer_indices(x, y, size, buffer)
      index1 = (x + 1) + y * size.x
      index2 = x + (y - 1) * size.x
      buffer.add_data index1
      buffer.add_data index2
    end

    private def create_transfer_indices_backwards(x, y, size, buffer)
      index1 = (x + 1) + y * size.x
      index2 = x + (y + 1) * size.x
      buffer.add_data index1
      buffer.add_data index2
    end

    private def create_column_indices(x, y, size, buffer)
      while y < size.y
        index1 = (x + 1) + y * size.x
        buffer.add_data index1
        if y + 1 < size.y
          index2 = x + (y + 1) * size.x
          buffer.add_data index2
        end
        y += 1
      end
    end

    private def create_column_indices_backwards(x, y, size, buffer)
      while y >= 0
        index1 = (x + 1) + y * size.x
        buffer.add_data index1
        if y - 1 >= 0
          index2 = x + (y - 1) * size.x
          buffer.add_data index2
        end
        y -= 1
      end
    end

    private def get_vertex_color(terrain : TerrainType)
      terrain.color.to_f32
    end

    private def get_vertex_color(val : Nil)
      Boleite::Color.black.to_f32
    end
  end
end