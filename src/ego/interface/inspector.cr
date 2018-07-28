class Inspector
  include CrystalClear

  TILE_INFO_SIZE = Boleite::Vector2f.new 200.0, 100.0
  ENTITY_INFO_SIZE = Boleite::Vector2f.new 200.0, 100.0

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
        close_entity window
      end
    end
    @entity_windows = [] of Boleite::GUI::Window
    @gui = nil
  end

  private def update_tile_info(coords : Nil)
    @window.clear
    info_box = Boleite::GUI::Layout.new :vertical
    text = Boleite::GUI::TextBox.new "None selected", TILE_INFO_SIZE
    text.character_size = 12u32
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
      text = Boleite::GUI::TextBox.new str, TILE_INFO_SIZE
      text.character_size = 12u32
      info_box.add text

      @world.entities.each_at(coords) do |entity|
        button = Boleite::GUI::Button.new entity.template.name, Boleite::Vector2f.new(TILE_INFO_SIZE.x, 26.0)
        button.click.on { open_entity entity }
        info_box.add button
      end
    end
    @window.add info_box
    @window.pulse.emit
  end

  requires @gui != nil
  def open_entity(entity)
    if gui = @gui
      position = entity.position
      window = Boleite::GUI::Window.new
      window.header_text = "#{position.x}x#{position.y} #{entity.template.name}"
      window.set_next_to @window
      window.add_close_button { close_entity window }
      window.pulse.on { close_entity window if entity.destroyed? }

      desc = create_entity_description entity
      window.add desc

      gui.add_root window
      @entity_windows << window
    end
  end

  requires @entity_windows.includes? window
  requires @gui != nil
  def close_entity(window)
    if gui = @gui
      gui.remove_root window
      @entity_windows.delete window
    end
  end

  def create_entity_description(entity)
    desc = Boleite::GUI::TextBox.new entity.template.description, ENTITY_INFO_SIZE
    desc.character_size = 12u32
    desc
  end
end