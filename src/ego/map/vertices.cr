class MapRenderer
  class Vertices
    struct Vertex < Boleite::Vertex
      @pos : Boleite::Vector4f32
      @color : Boleite::Vector4f32
  
      getter pos, color

      def initialize()
        @pos = Boleite::Vector4f32.zero
        @color = Boleite::Vector4f32.zero
      end
  
      def initialize(x, y, z, @color)
        @pos = Boleite::Vector4f32.new x.to_f32, y.to_f32, z.to_f32, 1f32
      end
    end

    property need_update, vbo

    @need_update = true
    @vbo : Boleite::VertexBufferObject?
    @target_height = 0u8

    def initialize(@target_height)
    end

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
      vertices = StaticArray(Vertex, 8).new Vertex.new
      order = { 0, 1, 2, 0, 2, 3,
                0, 4, 5, 5, 1, 0,
                2, 1, 6, 6, 7, 2 }
      flip_x, flip_y = calculate_ranges map
      size = map.size
      size.y.times do |iy|
        iy = size.y - iy - 1 if flip_y
        size.x.times do |ix|
          ix = size.x - ix - 1 if flip_x
          point = Map::Pos.new(ix.to_u16, iy.to_u16)
          rot = point.rotate_by map
          height = map.get_height point
          next if height != @target_height
          left, right = calculate_heights height, point, map
          terrain = map.get_terrain point
          color = get_vertex_color height, terrain
          pos = point.create_vertices_for_render map
          vertices[0] = Vertex.new pos[0].x, pos[0].y, rot.y + rot.x, color
          vertices[1] = Vertex.new pos[3].x, pos[3].y, rot.y + rot.x, color
          vertices[2] = Vertex.new pos[2].x, pos[2].y, rot.y + rot.x, color
          vertices[3] = Vertex.new pos[1].x, pos[1].y, rot.y + rot.x, color
          vertices[4] = Vertex.new pos[0].x, pos[0].y + Map::TILE_HEIGHT_SHIFT * left, rot.y + rot.x, Boleite::Color.white
          vertices[5] = Vertex.new pos[3].x, pos[3].y + Map::TILE_HEIGHT_SHIFT * left, rot.y + rot.x, Boleite::Color.white
          vertices[6] = Vertex.new pos[3].x, pos[3].y + Map::TILE_HEIGHT_SHIFT * right, rot.y + rot.x, Boleite::Color.white
          vertices[7] = Vertex.new pos[2].x, pos[2].y + Map::TILE_HEIGHT_SHIFT * right, rot.y + rot.x, Boleite::Color.white

          order.each do |index|
            buffer.add_data vertices[index]
          end
        end
      end
    end

    private def calculate_ranges(map)
      {map.view_rotation > 0 && map.view_rotation < 3, map.view_rotation > 1}
    end

    private def calculate_heights(height, point, map)
      left = 0u8
      ld = rotate_dir 0, 1, map.view_rotation
      rd = rotate_dir 1, 0, map.view_rotation
      lp = Map::Pos.new point.x + ld[0], point.y + ld[1]
      left = map.get_height lp if map.inside? lp
      right = 0u8
      rp = Map::Pos.new point.x + rd[0], point.y + rd[1]
      right = map.get_height rp if map.inside? rp

      {height - {left, height}.min, height - {right, height}.min}
    end

    private def rotate_dir(x : Int32, y : Int32, rotation, depth=0)
      x, y = rotate_dir -y, x, rotation, depth+1 if depth < rotation
      {x, y}
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
