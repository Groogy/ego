class EscapeMenuHotKey
  def interested?(event : Boleite::InputEvent) : Bool
    if event.is_a? Boleite::KeyEvent && event.action == Boleite::InputAction::Release
      return event.key == Boleite::Key::Escape
    end
    return false
  end

  def translate(event : Boleite::InputEvent)
    Tuple.new
  end
end

class RotateMapKey
  @map = {
    Boleite::Key::Q => -1, Boleite::Key::E => 1
  }
  def interested?(event : Boleite::InputEvent) : Bool
    if event.is_a? Boleite::KeyEvent && event.action == Boleite::InputAction::Release
      return @map.keys.includes? event.key
    end
    return false
  end

  def translate(event : Boleite::InputEvent)
    event = event.as(Boleite::KeyEvent)
    event.claim
    {@map[event.key]}
  end
end

class GameStateInputHandler < Boleite::InputReceiver
  def initialize(@interface : GameStateInterface, @world : World)
    register EscapeMenuHotKey, ->on_escape_hot_key
    register RotateMapKey, ->on_rotate_map_key(Int32)
  end

  def on_escape_hot_key
    @interface.show_escape_menu
  end

  def on_rotate_map_key(dir)
    @world.map.rotate_view dir
  end
end