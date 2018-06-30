class EntityRenderer
  class Vertices
    struct Vertex < Boleite::Vertex
      @pos : Boleite::Vector4f32
      @uv : Boleite::Vector2f32
      @color : Boleite::Vector4f32
  
      property pos, uv, color

      def initialize()
        @pos = Boleite::Vector4f32.zero
        @uv = Boleite::Vector2f32.zero
        @color = Boleite::Color.white
      end

      def initialize(pos, z)
        @pos = Boleite::Vector4f32.new pos.x.to_f32, pos.y.to_f32, z.to_f32, 1f32
        @uv = Boleite::Vector2f32.zero
        @color = Boleite::Color.white
      end
  
      def initialize(x, y, z)
        @pos = Boleite::Vector4f32.new x.to_f32, y.to_f32, z.to_f32, 1f32
        @uv = Boleite::Vector2f32.zero
        @color = Boleite::Color.white
      end

      def initialize(pos, z, u, v)
        @pos = Boleite::Vector4f32.new pos.x.to_f32, pos.y.to_f32, z.to_f32, 1f32
        @uv = Boleite::Vector2f32.new u.to_f32, v.to_f32
        @color = Boleite::Color.white
      end
  
      def initialize(x, y, z, u, v)
        @pos = Boleite::Vector4f32.new x.to_f32, y.to_f32, z.to_f32, 1f32
        @uv = Boleite::Vector2f32.new u.to_f32, v.to_f32
        @color = Boleite::Color.white
      end
    end

    property need_update, vbo

    @need_update = true
    @vbo : Boleite::VertexBufferObject?

    def initialize
    end

    def get_vertices(selected_tile, entities, map, gfx) : Boleite::VertexBufferObject
      vbo = @vbo
      if vbo.nil?
        vbo = create_vbo gfx
        @vbo = vbo
      end
      if @need_update
        update_vbo selected_tile, entities, map, vbo 
        @need_update = false
      end
      vbo
    end
  
    private def create_vbo(gfx) : Boleite::VertexBufferObject
      layout = Boleite::VertexLayout.new [
        Boleite::VertexAttribute.new(0, 4, :float, 40u32, 0u32,  0u32),
        Boleite::VertexAttribute.new(0, 2, :float, 40u32, 16u32, 0u32),
        Boleite::VertexAttribute.new(0, 4, :float, 40u32, 24u32, 0u32)
      ]
      vbo = gfx.create_vertex_buffer_object
      vbo.layout = layout
      vbo.primitive = Boleite::Primitive::Triangles
      vbo.create_buffer
      vbo
    end
  
    private def update_vbo(selected_tile, entities, map, vbo)
      vertices = vbo.get_buffer 0
      vertices.clear
      create_vertices selected_tile, entities, map, vertices
    end

    private def create_vertices(selected_tile, entities, map, buffer)
      create_vertices_for_selection selected_tile, map, buffer if selected_tile
      entities.each do |entity|
        create_vertices_for_entity entity, map, buffer if entity.position.on_map?
      end
    end

    private def create_vertices_for_entity(entity, map, buffer)
      order = {
        0, 2, 1,
        0, 1, 3,
        1, 4, 3
      }

      vertices = calculate_vertices_for entity.template, entity.position.point, map
      order.each { |index| buffer.add_data vertices[index] }
    end

    private def calculate_vertices_for(tmpl, pos, map)
      graphics = tmpl.graphics
      uv = graphics.uv.to_f
      uv_size = graphics.uv_size.to_f
      points = pos.create_vertices_for_render map
      points = adjust_vertex_points points, tmpl
      depth = calculate_depth pos, map
      sprite_height = graphics.height
      
      left = Vertex.new points[0], depth, uv.x - uv_size.x / 2, uv.y + uv_size.y - sprite_height
      right = Vertex.new points[2], depth, uv.x + uv_size.x / 2, uv.y + uv_size.y - sprite_height
      bottom = Vertex.new points[3], depth, uv.x, uv.y
      upper_left = Vertex.new points[0].x, points[0].y - sprite_height / 4, depth, uv.x - uv_size.x / 2, uv.y + uv_size.y
      upper_right = Vertex.new points[2].x, points[2].y - sprite_height / 4, depth, uv.x + uv_size.x / 2, uv.y + uv_size.y
      return left, right, bottom, upper_left, upper_right
    end

    def adjust_vertex_points(points, tmpl)
      area = (tmpl.size.to_f - 1.0) * Boleite::Vector2f.new(Map::TILE_WIDTH / 2.0, Map::TILE_HEIGHT / 2.0)
      {points[0] + Boleite::Vector2f.new(-area.x, -area.y), points[1],
      points[2] + Boleite::Vector2f.new(area.x, -area.y), points[3]}
    end

    private def calculate_depth(pos, map)
      rot = pos.rotate_by map
      rot.x + rot.y
    end

    private def create_vertices_for_selection(pos, map, buffer)
      rot = pos.rotate_by map
      raw = pos.create_vertices_for_render map
      depth = map.size.x + map.size.y + 1

      indices = {
        0, 4, 1, 4, 5, 1,
        1, 5, 2, 5, 6, 2,
        2, 6, 3, 6, 7, 3,
        3, 7, 0, 7, 4, 0
      }

      vertices = {
        Vertex.new(raw[0], depth),
        Vertex.new(raw[1], depth),
        Vertex.new(raw[2], depth),
        Vertex.new(raw[3], depth),
        Vertex.new(raw[0].x + 2, raw[0].y, depth),
        Vertex.new(raw[1].x, raw[1].y + 2, depth),
        Vertex.new(raw[2].x - 2, raw[2].y, depth),
        Vertex.new(raw[3].x, raw[3].y - 2, depth),
      }

      vertices.each &.color=(Boleite::Color.black)

      indices.each do |index|
        buffer.add_data vertices[index]
      end
    end
  end
end
