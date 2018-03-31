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
      vbo.primitive = Boleite::Primitive::Points
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
      size.y.times do |y|
        size.x.times do |x|
          terrain = map.get_terrain x, y
          color = get_vertex_color(terrain)
          vertex1 = Vertex.new [x.to_f32 * 16f32, y.to_f32 * 16f32, 0f32, 1f32], color
          buffer.add_data vertex1
        end
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