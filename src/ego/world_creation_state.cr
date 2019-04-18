class WorldCreationState < Boleite::State
  @frame_time = Time::Span.zero  

  def initialize(@app : EgoApplication)
    super()
    
    @update_gui = true
    gfx = @app.graphics
    target = gfx.main_target
    @camera2d = Boleite::Camera2D.new target.width.to_f32, target.height.to_f32, 0f32, 1f32
    @camera3d = Boleite::Camera3D.new 60f32, target.width.to_f32, target.height.to_f32, 10f32, 2500f32
    shader = Boleite::Shader.load_file "resources/shaders/test.shader", gfx
    @renderer = Boleite::ForwardRenderer.new gfx, @camera3d, shader
    @camera3d.rotate Math::PI / 4, 0.0, 0.0
    @camera3d.move 1024.0, 1000.0, -300.0
    
    @gui = Boleite::GUI.new gfx, Boleite::Font.new(gfx, "resources/fonts/arial.ttf")
    @desktop = Boleite::GUI::Desktop.new
    @desktop.size = target.size.to_f

    world_size = Defines.world_size.to_u32
    @generator = WorldGenerator.new Boleite::Vector2u.new(world_size, world_size)

    map = @generator.world.map
    sprite_size = target.size / 4
    sprite_size.y = sprite_size.x
    target_size = target.size.to_f
    @heat_sprite = Boleite::Sprite.new map.heat.generate_texture gfx
    @heat_sprite.position = Boleite::Vector2f.new target_size.x - sprite_size.x, target_size.y - sprite_size.y
    @heat_sprite.size = sprite_size

    @humidity_sprite = Boleite::Sprite.new map.humidity.generate_texture gfx
    @humidity_sprite.position = Boleite::Vector2f.new 0.0, target_size.y - sprite_size.y
    @humidity_sprite.size = sprite_size

    @map_renderer = MapRenderer.new
  end

  def enable
    @gui.enable @app.input_router
    @gui.add_root @desktop
  end

  def disable
    @gui.disable @app.input_router
    @gui.remove_root @desktop
  end

  def update(delta)
    if @update_gui
      build_gui
      @update_gui = false
    end

    target = Time::Span.new seconds: 0, nanoseconds: 1_000_000
    @frame_time += delta
    if @frame_time >= target
      @frame_time = Time::Span.zero
      @generator.update
    end
  end

  def render(delta)
    @renderer.clear Boleite::Color.black
    @renderer.camera = @camera3d
    render_world
    
    @renderer.camera = @camera2d
    @gui.render
    update_maps
    render_maps
    @renderer.present
  end

  def render_world
    world = @generator.world
    @map_renderer.render world.map, @renderer
  end

  def render_maps
    @renderer.draw @heat_sprite
    @renderer.draw @humidity_sprite
  end

  def update_maps
    map = @generator.world.map
    gfx = @app.graphics
    map.heat.generate_texture gfx
    map.humidity.generate_texture gfx

    @heat_sprite.color = Boleite::Colorf.new 1f32/30f32, 0f32, 0f32, 1f32
  end

  def start_world
    #world.generate_map
    #state = GameState.new @app, world
    #@app.state_stack.replace state
  end

  def build_gui
    @desktop.clear
    
    layout = Boleite::GUI::Layout.new :horizontal
    left_layout = Boleite::GUI::Layout.new :vertical
    right_layout = Boleite::GUI::Layout.new :vertical

    story = @generator.create_story
    textbox = Boleite::GUI::TextBox.new story, Boleite::Vector2f.new(500.0, 200.0)
    right_layout.add textbox

    @generator.each_available_myth do |m|
      text = m.generate_text @generator.world, @generator.deity
      label = Boleite::GUI::Label.new text, Boleite::Vector2f.new(700.0, 60.0)
      label.character_size = 32u32
      label.mouse_enter.on &-> { label.color = Boleite::Color.red }
      label.mouse_leave.on &-> { label.color = Boleite::Color.white }
      label.left_click.on &->(p : Boleite::Vector2f) do 
        @generator.select_myth m
        build_gui
      end
      left_layout.add label
    end

    layout.add left_layout
    layout.add right_layout

    @desktop.add layout
  end
end
