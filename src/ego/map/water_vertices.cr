class MapRenderer
  class WaterVertices
    struct Vertex < Boleite::Vertex
      @pos = Boleite::Vector4f32.zero
      @uv = Boleite::Vector2f32.zero

      property pos, uv

      def initialize(x, y, z, u, v)
        @pos.x = x
        @pos.y = y
        @pos.z = z
        @pos.w = 1f32
        @uv.x = u
        @uv.y = v
      end
    end

    @need_update = true
    @vbo : Boleite::VertexBufferObject?

    property need_update
    getter vbo

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
        Boleite::VertexAttribute.new(0, 4, :float, 24u32, 0u32, 0u32),
        Boleite::VertexAttribute.new(0, 2, :float, 24u32, 16u32, 0u32),
      ]
      vbo = gfx.create_vertex_buffer_object
      vbo.layout = layout
      vbo.primitive = Boleite::Primitive::TrianglesStrip
      vbo.create_buffer
      vbo
    end

    private def update_vbo(map, vbo)
      size = map.size.to_f32
      pos = {
        Vertex.new(0f32, 0f32, 0f32, 0f32, 0f32), Vertex.new(size.x, 0f32, 0f32, 1f32, 0f32),
        Vertex.new(0f32, 0f32, size.y, 0f32, 1f32), Vertex.new(size.x, 0f32, size.y, 1f32, 1f32),
      }
      vertices = vbo.get_buffer 0
      vertices.clear
      pos.each do |p|
        vertices.add_data p
      end
    end
  end
end
