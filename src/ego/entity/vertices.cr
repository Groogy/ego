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

      def initialize(pos)
        @pos = Boleite::Vector4f32.new pos.x.to_f32, pos.y.to_f32, 0f32, 1f32
        @uv = Boleite::Vector2f32.zero
        @color = Boleite::Color.white
      end
  
      def initialize(x, y)
        @pos = Boleite::Vector4f32.new x.to_f32, y.to_f32, 0f32, 1f32
        @uv = Boleite::Vector2f32.zero
        @color = Boleite::Color.white
      end

      def initialize(pos, u, v)
        @pos = Boleite::Vector4f32.new pos.x.to_f32, pos.y.to_f32, 0f32, 1f32
        @uv = Boleite::Vector2f32.new u.to_f32, v.to_f32
        @color = Boleite::Color.white
      end
  
      def initialize(x, y, u, v)
        @pos = Boleite::Vector4f32.new x.to_f32, y.to_f32, 0f32, 1f32
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
      tmpl = entity.template
      area = tmpl.size
      base_pos = entity.position.point
      area.y.times do |y|
        area.x.times do |x|
          pos = base_pos
          pos.x += x
          pos.y += y
          create_vertices_for_pos tmpl, pos, base_pos, map, buffer
        end
      end
    end

    private def create_vertices_for_pos(tmpl, pos, base_pos, map, buffer)
      order = {
        0, 2, 3,
        0, 3, 1
      }
      diff = pos - base_pos
      uv_offset = Boleite::Vector2i.new Map::TILE_WIDTH * diff.x, Map::TILE_WIDTH * (tmpl.size.y - diff.y)
      vertices = calculate_square_vertices_for tmpl, pos, uv_offset, map
      order.each { |index| buffer.add_data vertices[index] }
    end

    private def calculate_square_vertices_for(tmpl, pos, uv_offset, map)
      uv = tmpl.graphics.uv.to_i + uv_offset
      rot = pos.rotate_by map
      bounds = rot.to_rect.bounds
      
      upper_left = Vertex.new bounds[0].x, bounds[0].y, uv.x, uv.y
      upper_right = Vertex.new bounds[1].x, bounds[0].y, uv.x + Map::TILE_WIDTH, uv.y
      bottom_left = Vertex.new bounds[0].x, bounds[1].y, uv.x, uv.y - Map::TILE_WIDTH
      bottom_right = Vertex.new bounds[1].x, bounds[1].y, uv.x + Map::TILE_WIDTH, uv.y - Map::TILE_WIDTH

      return upper_left, upper_right, bottom_left, bottom_right
    end

    private def create_vertices_for_selection(pos, map, buffer)
      rot = pos.rotate_by map
      bounds = rot.to_rect.bounds
      smaller_bounds = rot.to_rect.shrink(2).bounds
      indices = {
        0, 3, 7, 0, 7, 4, 
        0, 4, 1, 4, 5, 1,
        1, 5, 6, 6, 2, 1,
        2, 6, 3, 3, 6, 7
      }

      vertices = {
        Vertex.new(bounds[0].x, bounds[0].y),
        Vertex.new(bounds[1].x, bounds[0].y),
        Vertex.new(bounds[1].x, bounds[1].y),
        Vertex.new(bounds[0].x, bounds[1].y),
        Vertex.new(smaller_bounds[0].x, smaller_bounds[0].y),
        Vertex.new(smaller_bounds[1].x, smaller_bounds[0].y),
        Vertex.new(smaller_bounds[1].x, smaller_bounds[1].y),
        Vertex.new(smaller_bounds[0].x, smaller_bounds[1].y),
      }

      vertices.each &.color=(Boleite::Color.black)

      indices.each do |index|
        buffer.add_data vertices[index]
      end
    end
  end
end
