class GameStateInterface
  @gui : Boleite::GUI

  getter control_menu

  def initialize(@gui, app, world)
    @control_menu = ControlMenu.new world
    @debug_stats_viewer = DebugStatsViewer.new @gui.target_size, world
    @game_menu = GameMenu.new @gui, app, world
  end

  def update(full_update)
    @control_menu.update if full_update
    @debug_stats_viewer.update full_update
  end

  def show_escape_menu
    @game_menu.show
  end

  def enable
    @gui.add_root @control_menu.window
    @gui.add_root @debug_stats_viewer.window
    @gui.add_root @game_menu.window
  end

  def disable
    @gui.remove_root @control_menu.window
    @gui.remove_root @debug_stats_viewer.window
    @gui.remove_root @game_menu.window
  end
end