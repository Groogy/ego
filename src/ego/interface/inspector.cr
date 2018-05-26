class Inspector
  @world : World
  @camera : Boleite::Camera2D
  @selected_tile : Map::Pos?
  @input = Boleite::InputReceiver.new
  @gui : Boleite::GUI?
  @entity_windows = [] of Boleite::GUI::Window

  getter window, selected_tile

  def initialize(@world, @camera)
    @window = Boleite::GUI::Window.new
    @window.header_text = "Inspector"
    @window.position = Boleite::Vector2f.new 310.0, @window.header_size

    @input.register_instance InspectorClickInput.new(@world, @camera), ->select_tile(Map::Pos?)

    update_tile_info @selected_tile
  end

  def select_tile(coords : Map::Pos?)
    @selected_tile = coords
    @world.entities.renderer.selected_tile = coords
    update_tile_info coords
  end

  def enable(app, @gui)
    if gui = @gui
      gui.add_root @window
    end
    app.input_router.register @input
  end

  def disable(app)
    app.input_router.unregister @input
    if gui = @gui
      gui.remove_root @window
      @entity_windows.each do |window|
        gui.remove_root window
      end
    end
    @entity_windows = [] of Boleite::GUI::Window
    @gui = nil
  end

  private def update_tile_info(coords : Nil)
    @window.clear
    info_box = Boleite::GUI::Layout.new :vertical
    text = Boleite::GUI::TextBox.new "None selected", Boleite::Vector2f.new(200.0, 200.0)
    text.character_size = 14u32
    info_box.add text
    @window.add info_box
  end

  private def update_tile_info(coords : Map::Pos)
    @window.clear
    info_box = Boleite::GUI::Layout.new :vertical
    info_box.pulse.on do
      terrain = @world.map.get_terrain(coords)
      str = "#{coords.x}x#{coords.y}\n"
      str += terrain.name if terrain
      info_box.clear
      text = Boleite::GUI::TextBox.new str, Boleite::Vector2f.new(200.0, 200.0)
      info_box.add text

      @world.entities.each_at(coords) do |entity|
        button = Boleite::GUI::Button.new entity.template.name, Boleite::Vector2f.new(200.0, 26.0)
        button.click.on { open_entity entity }
        info_box.add button
      end
    end
    @window.add info_box
    @window.pulse.emit
  end

  def open_entity(entity)
    pp entity.template.name
    if gui = @gui
      position = entity.position
      window = Boleite::GUI::Window.new
      window.header_text = "#{position.x}x#{position.y} #{entity.template.name}"
      window.size = Boleite::Vector2f.new(200.0, 200.0)
      window.set_next_to @window
      gui.add_root window
      @entity_windows << window
    end
  end
end