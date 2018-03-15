class GameStateInterface
  @gui : Boleite::GUI
  @world : World

  getter control_menu

  def initialize(@gui, @world)
    @control_menu = ControlMenu.new @gui, @world
  end

  def update
    @control_menu.update
  end
end