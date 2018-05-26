class GameStateInterface
  @gui : Boleite::GUI

  getter control_menu, inspector

  def initialize(@gui, app, world, camera)
    @control_menu = ControlMenu.new world
    @toolbox = Toolbox.new world, camera
    @debug_stats_viewer = DebugStatsViewer.new @gui.target_size, world
    @game_menu = GameMenu.new @gui, app, world
    @inspector = Inspector.new world, camera
  end

  def update(full_update)
    @control_menu.update if full_update
    @debug_stats_viewer.update full_update
  end

  def show_escape_menu
    @game_menu.show
  end

  def enable(app)
    @gui.add_root @control_menu.window
    @gui.add_root @toolbox.window
    @gui.add_root @debug_stats_viewer.window
    @gui.add_root @game_menu.window

    @toolbox.enable app
    @inspector.enable app, @gui
  end

  def disable(app)
    @inspector.disable app
    @toolbox.disable app
    @gui.remove_root @control_menu.window
    @gui.remove_root @toolbox.window
    @gui.remove_root @debug_stats_viewer.window
    @gui.remove_root @game_menu.window
  end
end