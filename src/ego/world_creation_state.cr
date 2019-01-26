class WorldCreationState < Boleite::State
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

    @generator = WorldGenerator.new
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
    @renderer.present
  end

  def start_world
    #world.generate_map
    #state = GameState.new @app, world
    #@app.state_stack.replace state
  end

  def build_gui
    @desktop.clear
    layout = Boleite::GUI::Layout.new :vertical

    @generator.each_available_myth do |m|
      label = Boleite::GUI::Label.new m.text, Boleite::Vector2f.new(800.0, 60.0)
      label.character_size = 32u32
      label.mouse_enter.on &-> { label.color = Boleite::Color.red }
      label.mouse_leave.on &-> { label.color = Boleite::Color.white }
      label.left_click.on &->(p : Boleite::Vector2f) do 
        @generator.select_myth m
        build_gui
      end
      layout.add label
    end

    @desktop.add layout
  end
end