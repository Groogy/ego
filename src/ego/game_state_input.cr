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

class GameStateInputHandler < Boleite::InputReceiver
  def initialize(@interface : GameStateInterface)
    register EscapeMenuHotKey, ->on_escape_hot_key
  end

  def on_escape_hot_key
    @interface.show_escape_menu
  end
end