class TilemapRenderer
  struct Vertices
    struct Vertex < Boleite::Vertex
      @pos : Boleite::Vector4f32
      @uv : Boleite::Vector2f32
  
      getter pos, uv
  
      def initialize(pos, uv)
        @pos = Boleite::Vector4f32.new(pos)
        @uv = Boleite::Vector2f32.new(uv)
      end
  
      def height
        @pos.y
      end
  
      def height=(val)
        @pos.y = val
      end
    end

    property need_update, vbo

    @need_update = true
    @vbo : Boleite::VertexBufferObject?

    def get_vertices(tilemap, tileset_size, gfx) : Boleite::VertexBufferObject
      vbo = @vbo
      if vbo.nil?
        vbo = create_vertices gfx
        @vbo = vbo
      end
      if @need_update
        update_vertices tilemap, tileset_size, vbo 
        @need_update = false
      end
      vbo
    end
  
    private def create_vertices(gfx) : Boleite::VertexBufferObject
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
  
    private def update_vertices(tilemap, tileset_size, vbo)
      buffer = vbo.get_buffer 0
      buffer.clear
      tilemap.each_tile do |tile, coord|
        if type = tile.tile_type
          surrounding = tilemap.get_surrounding_tiles coord
          build_vertices_for_tile tile, type, coord, tileset_size, surrounding, buffer
        end
      end
    end
  
    private def build_vertices_for_tile(tile, type, coord, tileset_size, surrounding, buffer)
      coord = coord.to_f32
      uv = type.uv.to_f32 / tileset_size.to_f32
      extent = Boleite::Vector2f32.new TILE_SIZE / tileset_size.x, TILE_SIZE / tileset_size.y
      height = tile.height.to_f32
  
      if tile.is_ramp?
        build_ramp_tile buffer, coord, height, uv, extent, surrounding
      else
        build_flat_tile buffer, coord, height, uv, extent, surrounding
      end
    end
  
    private def build_flat_tile(buffer, coord, height, uv, extent, surrounding)
      build_roof_for_tile buffer, coord, height, uv, extent
      if side = surrounding[0]
        build_north_wall_for_tile buffer, coord, height, side.height, uv, extent if side.is_ramp? == false && side.height < height
      end
      if side = surrounding[1]
        build_east_wall_for_tile buffer, coord, height, side.height, uv, extent if side.is_ramp? == false && side.height < height
      end
      if side = surrounding[2]
        build_south_wall_for_tile buffer, coord, height, side.height, uv, extent if side.is_ramp? == false && side.height < height
      end
      if side = surrounding[3]
        build_west_wall_for_tile buffer, coord, height, side.height, uv, extent if side.is_ramp? == false && side.height < height
      end
    end
  
    private def build_ramp_tile(buffer, coord, height, uv, extent, surrounding)
      top = calculate_ramp_top coord, height, uv, extent, surrounding
      buffer.add_data top[0]
      buffer.add_data top[2]
      buffer.add_data top[1]
      buffer.add_data top[1]
      buffer.add_data top[2]
      buffer.add_data top[3]
      build_ramp_walls buffer, top, coord, height, uv, extent, surrounding
    end
  
    private def build_roof_for_tile(buffer, coord, height, uv, extent)
      vertex1 = Vertex.new [coord.x,      height, coord.y,      1f32], [uv.x, uv.y]
      vertex2 = Vertex.new [coord.x,      height, coord.y+1f32, 1f32], [uv.x, uv.y+extent.y]
      vertex3 = Vertex.new [coord.x+1f32, height, coord.y,      1f32], [uv.x+extent.x, uv.y]
      vertex4 = Vertex.new [coord.x+1f32, height, coord.y+1f32, 1f32], [uv.x+extent.x, uv.y+extent.y]
      buffer.add_data vertex1
      buffer.add_data vertex3
      buffer.add_data vertex2
      buffer.add_data vertex2
      buffer.add_data vertex3
      buffer.add_data vertex4
    end
  
    private def build_north_wall_for_tile(buffer, coord, my_height, other_height, uv, extent)
      delta = my_height - other_height
      vertex1 = Vertex.new [coord.x,      my_height,         coord.y+1f32, 1f32], [uv.x,          uv.y+extent.y]
      vertex2 = Vertex.new [coord.x+1f32, my_height,         coord.y+1f32, 1f32], [uv.x+extent.x, uv.y+extent.y]
      vertex3 = Vertex.new [coord.x,      my_height - delta, coord.y+1f32, 1f32], [uv.x,          uv.y]
      vertex4 = Vertex.new [coord.x+1f32, my_height - delta, coord.y+1f32, 1f32], [uv.x+extent.x, uv.y]
      buffer.add_data vertex1
      buffer.add_data vertex2
      buffer.add_data vertex3
      buffer.add_data vertex2
      buffer.add_data vertex4
      buffer.add_data vertex3
    end
  
    private def build_east_wall_for_tile(buffer, coord, my_height, other_height, uv, extent)
      delta = my_height - other_height
      vertex1 = Vertex.new [coord.x+1f32, my_height,         coord.y,      1f32], [uv.x,          uv.y+extent.y]
      vertex2 = Vertex.new [coord.x+1f32, my_height,         coord.y+1f32, 1f32], [uv.x+extent.x, uv.y+extent.y]
      vertex3 = Vertex.new [coord.x+1f32, my_height - delta, coord.y,      1f32], [uv.x,          uv.y]
      vertex4 = Vertex.new [coord.x+1f32, my_height - delta, coord.y+1f32, 1f32], [uv.x+extent.x, uv.y]
      buffer.add_data vertex1
      buffer.add_data vertex3
      buffer.add_data vertex2
      buffer.add_data vertex2
      buffer.add_data vertex3
      buffer.add_data vertex4
    end
  
    private def build_south_wall_for_tile(buffer, coord, my_height, other_height, uv, extent)
      delta = my_height - other_height
      vertex1 = Vertex.new [coord.x,      my_height,         coord.y, 1f32], [uv.x,          uv.y+extent.y]
      vertex2 = Vertex.new [coord.x+1f32, my_height,         coord.y, 1f32], [uv.x+extent.x, uv.y+extent.y]
      vertex3 = Vertex.new [coord.x,      my_height - delta, coord.y, 1f32], [uv.x,          uv.y]
      vertex4 = Vertex.new [coord.x+1f32, my_height - delta, coord.y, 1f32], [uv.x+extent.x, uv.y]
      buffer.add_data vertex1
      buffer.add_data vertex3
      buffer.add_data vertex2
      buffer.add_data vertex2
      buffer.add_data vertex3
      buffer.add_data vertex4
    end
  
    private def build_west_wall_for_tile(buffer, coord, my_height, other_height, uv, extent)
      delta = my_height - other_height
      vertex1 = Vertex.new [coord.x, my_height,         coord.y,      1f32], [uv.x,          uv.y+extent.y]
      vertex2 = Vertex.new [coord.x, my_height,         coord.y+1f32, 1f32], [uv.x+extent.x, uv.y+extent.y]
      vertex3 = Vertex.new [coord.x, my_height - delta, coord.y,      1f32], [uv.x,          uv.y]
      vertex4 = Vertex.new [coord.x, my_height - delta, coord.y+1f32, 1f32], [uv.x+extent.x, uv.y]
      buffer.add_data vertex1
      buffer.add_data vertex2
      buffer.add_data vertex3
      buffer.add_data vertex2
      buffer.add_data vertex4
      buffer.add_data vertex3
    end
  
    private def calculate_ramp_top(coord, height, uv, extent, surrounding)
      vertex1 = Vertex.new [coord.x,      height, coord.y,      1f32], [uv.x, uv.y]
      vertex2 = Vertex.new [coord.x,      height, coord.y+1f32, 1f32], [uv.x, uv.y+extent.y]
      vertex3 = Vertex.new [coord.x+1f32, height, coord.y,      1f32], [uv.x+extent.x, uv.y]
      vertex4 = Vertex.new [coord.x+1f32, height, coord.y+1f32, 1f32], [uv.x+extent.x, uv.y+extent.y]
      if side = surrounding[0]
        vertex2.height = side.height.to_f32 if side.height > vertex2.height
        vertex4.height = side.height.to_f32 if side.height > vertex4.height
      end
      if side = surrounding[1]
        vertex3.height = side.height.to_f32 if side.height > vertex3.height
        vertex4.height = side.height.to_f32 if side.height > vertex4.height
      end
      if side = surrounding[2]
        vertex1.height = side.height.to_f32 if side.height > vertex1.height
        vertex3.height = side.height.to_f32 if side.height > vertex3.height
      end
      if side = surrounding[3]
        vertex1.height = side.height.to_f32 if side.height > vertex1.height
        vertex2.height = side.height.to_f32 if side.height > vertex2.height
      end
      return vertex1, vertex2, vertex3, vertex4
    end
  
    private def build_ramp_walls(buffer, anchors, coord, height, uv, extent, surrounding)
      if side = surrounding[3]
        if side.height <= height && side.is_ramp? == false
          build_hori_ramp_wall_on_anchor buffer, anchors[1], -1f32, height, uv, extent, true if anchors[1].height > height
          build_hori_ramp_wall_on_anchor buffer, anchors[0],  1f32, height, uv, extent, false if anchors[0].height > height
        end
      end
      if side = surrounding[1]
        if side.height <= height && side.is_ramp? == false
          build_hori_ramp_wall_on_anchor buffer, anchors[2],  1f32, height, uv, extent, true if anchors[2].height > height
          build_hori_ramp_wall_on_anchor buffer, anchors[3], -1f32, height, uv, extent, false if anchors[3].height > height
        end
      end
      if side = surrounding[0]
        if side.height <= height && side.is_ramp? == false
          build_vert_ramp_wall_on_anchor buffer, anchors[3], -1f32, height, uv, extent, false if anchors[3].height > height
          build_vert_ramp_wall_on_anchor buffer, anchors[1],  1f32, height, uv, extent, true if anchors[1].height > height
        end
      end
      if side = surrounding[2]
        if side.height <= height && side.is_ramp? == false
          build_vert_ramp_wall_on_anchor buffer, anchors[2], -1f32, height, uv, extent, true if anchors[2].height > height
          build_vert_ramp_wall_on_anchor buffer, anchors[0],  1f32, height, uv, extent, false if anchors[0].height > height
        end
      end
    end
  
    private def build_hori_ramp_wall_on_anchor(buffer, anchor, dir, height, uv, extent, flip)
      vertex1 = Vertex.new [anchor.pos.x, anchor.height, anchor.pos.z,      1f32], [uv.x,          uv.y+extent.y]
      vertex2 = Vertex.new [anchor.pos.x, height,        anchor.pos.z+dir,  1f32], [uv.x+extent.x, uv.y+extent.y]
      vertex3 = Vertex.new [anchor.pos.x, height,        anchor.pos.z,      1f32], [uv.x,          uv.y]
      buffer.add_data vertex1
      if flip
        buffer.add_data vertex3 
        buffer.add_data vertex2
      else
        buffer.add_data vertex2
        buffer.add_data vertex3
      end
    end
  
    private def build_vert_ramp_wall_on_anchor(buffer, anchor, dir, height, uv, extent, flip)
      vertex1 = Vertex.new [anchor.pos.x,     anchor.height, anchor.pos.z, 1f32], [uv.x,          uv.y+extent.y]
      vertex2 = Vertex.new [anchor.pos.x,     height,        anchor.pos.z, 1f32], [uv.x+extent.x, uv.y+extent.y]
      vertex3 = Vertex.new [anchor.pos.x+dir, height,        anchor.pos.z, 1f32], [uv.x,          uv.y]
      buffer.add_data vertex1
      if flip
        buffer.add_data vertex3 
        buffer.add_data vertex2
      else
        buffer.add_data vertex2
        buffer.add_data vertex3
      end
    end
  end
end