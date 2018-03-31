class MapRenderer
  struct Vertices
    struct Vertex < Boleite::Vertex
      @pos : Boleite::Vector4f32
      @color : Boleite::Vector4f32
  
      getter pos, color
  
      def initialize(x, y, @color)
        @pos = Boleite::Vector4f32.new x.to_f32, y.to_f32, 0f32, 1f32
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
      vbo.primitive = Boleite::Primitive::Triangles
      vbo.create_buffer
      vbo
    end
  
    private def update_vbo(map, vbo)
      vertices = vbo.get_buffer 0
      vertices.clear
      create_vertices map, vertices
    end

    private def create_vertices(map, buffer)
      size = map.size
      size.y.times do |iy|
        size.x.times do |ix|
          point = Map::Pos.new ix.to_u16, iy.to_u16
          height = map.get_height point
          terrain = map.get_terrain point
          color = get_vertex_color height, terrain
          pos = point.create_vertices
          vertex1 = Vertex.new pos[0].x + 1, pos[0].y, color
          vertex2 = Vertex.new pos[1].x, pos[1].y, color
          vertex3 = Vertex.new pos[2].x - 1, pos[2].y, color
          vertex4 = Vertex.new pos[3].x, pos[3].y, color
          buffer.add_data vertex1
          buffer.add_data vertex2
          buffer.add_data vertex3
          buffer.add_data vertex1
          buffer.add_data vertex3
          buffer.add_data vertex4
        end
      end
    end

    private def get_vertex_color(height, terrain : TerrainType)
      mod = 1f32 - height.to_f32 / Map::MAX_HEIGHT
      terrain.color.to_f32 * mod
    end

    private def get_vertex_color(height, val : Nil)
      Boleite::Color.black.to_f32
    end
  end
end