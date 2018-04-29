class EntityRenderer
  class Vertices
    struct Vertex < Boleite::Vertex
      @pos : Boleite::Vector4f32
      @uv : Boleite::Vector2f32
  
      getter pos, uv

      def initialize()
        @pos = Boleite::Vector4f32.zero
        @uv = Boleite::Vector2f32.zero
      end

      def initialize(pos, z, u, v)
        @pos = Boleite::Vector4f32.new pos.x.to_f32, pos.y.to_f32, z.to_f32, 1f32
        @uv = Boleite::Vector2f32.new u.to_f32, v.to_f32
      end
  
      def initialize(x, y, z, u, v)
        @pos = Boleite::Vector4f32.new x.to_f32, y.to_f32, z.to_f32, 1f32
        @uv = Boleite::Vector2f32.new u.to_f32, v.to_f32
      end
    end

    property need_update, vbo

    @need_update = true
    @vbo : Boleite::VertexBufferObject?

    def initialize
    end

    def get_vertices(entities, map, gfx) : Boleite::VertexBufferObject
      vbo = @vbo
      if vbo.nil?
        vbo = create_vbo gfx
        @vbo = vbo
      end
      if @need_update
        update_vbo entities, map, vbo 
        @need_update = false
      end
      vbo
    end
  
    private def create_vbo(gfx) : Boleite::VertexBufferObject
      layout = Boleite::VertexLayout.new [
        Boleite::VertexAttribute.new(0, 4, :float, 24u32, 0u32,  0u32),
        Boleite::VertexAttribute.new(0, 2, :float, 24u32, 16u32, 0u32)
      ]
      vbo = gfx.create_vertex_buffer_object
      vbo.layout = layout
      vbo.primitive = Boleite::Primitive::Triangles
      vbo.create_buffer
      vbo
    end
  
    private def update_vbo(entities, map, vbo)
      vertices = vbo.get_buffer 0
      vertices.clear
      create_vertices entities, map, vertices
    end

    private def create_vertices(entities, map, buffer)
      entities.each do |entity|
        create_vertices_for_entity entity, map, buffer if entity.position.on_map?
      end
    end

    private def create_vertices_for_entity(entity, map, buffer)
      graphics = entity.template.graphics
      uv = graphics.uv
      pos = entity.position.point
      rot = pos.rotate_by map
      vertices = pos.create_vertices_for_render map
      depth = rot.x + rot.y
      sprite_height = graphics.height
      left = Vertex.new vertices[0], depth, uv.x, uv.y + Map::TILE_HEIGHT_SHIFT
      right = Vertex.new vertices[2], depth, uv.x + Map::TILE_WIDTH, uv.y + Map::TILE_HEIGHT_SHIFT
      bottom = Vertex.new vertices[3], depth, uv.x + Map::TILE_WIDTH / 2, uv.y
      upper_left = Vertex.new vertices[0].x, vertices[0].y - sprite_height, depth, uv.x, uv.y + sprite_height
      upper_right = Vertex.new vertices[2].x, vertices[2].y - sprite_height, depth, uv.x + Map::TILE_WIDTH, uv.y + sprite_height

      buffer.add_data left
      buffer.add_data bottom
      buffer.add_data right

      buffer.add_data left
      buffer.add_data right
      buffer.add_data upper_left

      buffer.add_data right
      buffer.add_data upper_right
      buffer.add_data upper_left
    end
  end
end
