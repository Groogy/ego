class Inspector
  @world : World
  @camera : Boleite::Camera2D
  @selected_tile : Map::Pos?
  @input = Boleite::InputReceiver.new

  getter window

  def initialize(@world, @camera)
    @window = Boleite::GUI::Window.new
    @window.header_text = "Inspector"
    @window.position = Boleite::Vector2f.new 310.0, @window.header_size

    @input.register_instance InspectorClickInput.new(@world, @camera), ->select_tile(Map::Pos?)

    update_tile_info @selected_tile
  end

  def select_tile(coords : Map::Pos?)
    @selected_tile = coords
    update_tile_info @selected_tile
  end

  def enable(app)
    app.input_router.register @input
  end

  def disable(app)
    app.input_router.unregister @input
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
      info_box.clear
      text = Boleite::GUI::TextBox.new "#{coords.x}x#{coords.y}", Boleite::Vector2f.new(200.0, 200.0)
      info_box.add text
    end
    @window.add info_box
    @window.pulse.emit
  end
end