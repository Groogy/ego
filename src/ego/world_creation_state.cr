class WorldCreationState < Boleite::State
  MAP_DISPLAY_SIZE = 600u32
  WORLD_SIZE = 8192u32

  def initialize(@app : EgoApplication)
    super()
    
    @update_gui = true
    gfx = @app.graphics
    target = gfx.main_target
    @camera2d = Boleite::Camera2D.new(target.width.to_f32, target.height.to_f32, 0f32, 1f32)
    shader = Boleite::Shader.load_file "resources/shaders/test.shader", gfx
    @renderer = Boleite::ForwardRenderer.new gfx, @camera2d, shader
    
    @gui = Boleite::GUI.new gfx, Boleite::Font.new(gfx, "resources/fonts/arial.ttf")
    @desktop = Boleite::GUI::Desktop.new
    @desktop.size = target.size.to_f

    @generator = WorldGenerator.new Boleite::Vector2u.new(WORLD_SIZE, WORLD_SIZE)

    map = @generator.world.map
    target_size = target.size.to_f
    @terrain_sprite = Boleite::Sprite.new map.terrain.generate_texture gfx
    @height_sprite = Boleite::Sprite.new map.heightmap.generate_texture gfx
    @terrain_sprite.position = Boleite::Vector2f.new 0.0, target_size.y - MAP_DISPLAY_SIZE
    @height_sprite.position = Boleite::Vector2f.new target_size.x - MAP_DISPLAY_SIZE, target_size.y - MAP_DISPLAY_SIZE
    @terrain_sprite.size = Boleite::Vector2u.new MAP_DISPLAY_SIZE, MAP_DISPLAY_SIZE
    @height_sprite.size = Boleite::Vector2u.new MAP_DISPLAY_SIZE, MAP_DISPLAY_SIZE
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
  end

  def render(delta)
    @renderer.clear Boleite::Color.black
    @gui.render

    
    update_maps
    render_maps
    @renderer.present
  end

  def render_maps
    @renderer.draw @terrain_sprite
    @renderer.draw @height_sprite
  end

  def update_maps
    map = @generator.world.map
    gfx = @app.graphics
    map.terrain.generate_texture gfx
    map.heightmap.generate_texture gfx
    extremes = map.heightmap.extremes
    color = Boleite::Color.white
    color.r = 1f32 / extremes[1]
    @height_sprite.color = color
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