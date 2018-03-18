class GameStateInterface
  @gui : Boleite::GUI
  @world : World

  getter control_menu

  def initialize(@gui, @world)
    @control_menu = ControlMenu.new @gui, @world
    @debug_stats_viewer = DebugStatsViewer.new @gui, @world
  end

  def update(full_update)
    @control_menu.update if full_update
    @debug_stats_viewer.update full_update
  end
end