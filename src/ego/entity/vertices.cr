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
        #create_vertices_for_entity entity, map, buffer if entity.position.on_map?
      end
    end

    private def create_vertices_for_entity(entity, map, buffer)
      tmpl = entity.template
      area = tmpl.size
      uv_area = calculate_uv_area_for tmpl
      base_pos = entity.position.point
      area.y.times do |y|
        area.x.times do |x|
          pos = base_pos
          pos.x -= x
          pos.y -= y
          create_vertices_for_pos tmpl, pos, base_pos, uv_area, map, buffer
        end
      end
      if tmpl.graphics.height > 0
        create_top_vertices_for tmpl, base_pos, map, uv_area, buffer
      end
    end

    private def calculate_uv_area_for(tmpl)
      Boleite::Vector2f.new Map::TILE_WIDTH.to_f, Map::TILE_HEIGHT.to_f
    end

    private def create_vertices_for_pos(tmpl, pos, base_pos, uv_area, map, buffer)
      order = {
        3, 2, 0,
        2, 1, 0
      }
      diff = (base_pos - pos).translate_to_isometric
      offset = Boleite::Vector2f.new(-diff[0] / Map::TILE_WIDTH.to_f, diff[1] / Map::TILE_HEIGHT.to_f) * uv_area
      vertices = calculate_square_vertices_for tmpl, pos, offset, uv_area, map
      order.each { |index| buffer.add_data vertices[index] }
    end

    private def calculate_square_vertices_for(tmpl, pos, uv_offset, uv_area, map)
      graphics = tmpl.graphics
      uv = graphics.uv.to_f + uv_offset
      points = pos.create_vertices_for_render map
      depth = calculate_depth tmpl, pos, map
      
      left = Vertex.new points[0], depth, uv.x - uv_area.x / 2, uv.y + uv_area.y / 2
      top = Vertex.new points[1], depth, uv.x, uv.y + uv_area.y
      right = Vertex.new points[2], depth, uv.x + uv_area.x / 2, uv.y + uv_area.y / 2
      bottom = Vertex.new points[3], depth, uv.x, uv.y

      return left, top, right, bottom
    end

    private def create_top_vertices_for(tmpl, base_pos, map, uv_area, buffer)
      base_points = base_pos.create_vertices_for_render map
      left = calculate_left_top_vertex_for tmpl, base_pos, map, uv_area
      right = calculate_right_top_vertex_for tmpl, base_pos, map, uv_area
      middle = calculate_middle_top_vertex_for tmpl, base_pos, uv_area, map
      top_left = calculate_top_left_top_vertex_for tmpl, left, base_points, map
      top_right = calculate_top_right_top_vertex_for tmpl, right, base_points, map

      buffer.add_data left
      buffer.add_data middle
      buffer.add_data top_left

      buffer.add_data right
      buffer.add_data top_right
      buffer.add_data middle

      buffer.add_data top_left
      buffer.add_data middle
      buffer.add_data top_right
    end

    private def calculate_left_top_vertex_for(tmpl, base_pos, map, uv_area)
      gfx = tmpl.graphics
      left = base_pos
      left.x -= tmpl.size.x - 1
      depth = calculate_depth tmpl, left, map
      points = left.create_vertices_for_render map

      diff = (base_pos - left).translate_to_isometric
      uv = gfx.uv.to_f + Boleite::Vector2f.new(-diff[0] / Map::TILE_WIDTH.to_f, diff[1] / Map::TILE_HEIGHT.to_f) * uv_area

      Vertex.new points[0], depth, uv.x - uv_area.x / 2, uv.y + uv_area.y / 2
    end

    private def calculate_right_top_vertex_for(tmpl, base_pos, map, uv_area)
      gfx = tmpl.graphics
      right = base_pos
      right.y -= tmpl.size.y - 1
      depth = calculate_depth tmpl, right, map
      points = right.create_vertices_for_render map

      diff = (base_pos - right).translate_to_isometric
      uv = gfx.uv.to_f + Boleite::Vector2f.new(-diff[0] / Map::TILE_WIDTH.to_f, diff[1] / Map::TILE_HEIGHT.to_f) * uv_area

      Vertex.new points[2], depth, uv.x + uv_area.x / 2, uv.y + uv_area.y / 2
    end

    private def calculate_middle_top_vertex_for(tmpl, base_pos, uv_area, map)
      middle = base_pos - tmpl.size + 1
      depth = calculate_depth tmpl, middle, map
      points = middle.create_vertices_for_render map

      uv = tmpl.graphics.uv.to_f
      uv.y += uv_area.y * tmpl.size.y

      Vertex.new points[1], depth, uv.x, uv.y
    end

    private def calculate_top_left_top_vertex_for(tmpl, base_vert, base_points, map)
      gfx = tmpl.graphics
      point = base_points[3]
      uv = base_vert.uv
      uv.y = gfx.uv.y.to_f32 + gfx.height.to_f32
      y = point.y - gfx.height
      Vertex.new base_vert.pos.x, y, base_vert.pos.z, uv.x, uv.y
    end

    private def calculate_top_right_top_vertex_for(tmpl, base_vert, base_points, map)
      gfx = tmpl.graphics
      point = base_points[3]
      uv = base_vert.uv
      uv.y = gfx.uv.y.to_f32 + gfx.height.to_f32
      y = point.y - gfx.height
      Vertex.new base_vert.pos.x, y, base_vert.pos.z, uv.x, uv.y
    end

    private def calculate_depth(tmpl, pos, map)
      rot = pos.rotate_by map
      rot.x + rot.y
    end

    private def create_vertices_for_selection(pos, map, buffer)
      rot = pos.rotate_by map
      bounds = pos.to_rect.bounds
      smaller_bounds = pos.to_rect.shrink(2).bounds
      depth = map.size.x + map.size.y + 1

      indices = {
        0, 3, 7, 0, 7, 4, 
        0, 4, 1, 4, 5, 1,
        1, 5, 6, 6, 2, 1,
        2, 6, 3, 3, 6, 7
      }

      vertices = {
        Vertex.new(bounds[0].x, bounds[0].y, depth),
        Vertex.new(bounds[1].x, bounds[0].y, depth),
        Vertex.new(bounds[1].x, bounds[1].y, depth),
        Vertex.new(bounds[0].x, bounds[1].y, depth),
        Vertex.new(smaller_bounds[0].x, smaller_bounds[0].y, depth),
        Vertex.new(smaller_bounds[1].x, smaller_bounds[0].y, depth),
        Vertex.new(smaller_bounds[1].x, smaller_bounds[1].y, depth),
        Vertex.new(smaller_bounds[0].x, smaller_bounds[1].y, depth),
      }

      vertices.each &.color=(Boleite::Color.black)

      indices.each do |index|
        buffer.add_data vertices[index]
      end
    end
  end
end
