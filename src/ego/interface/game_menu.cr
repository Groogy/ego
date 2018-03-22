class GameMenu
  @gui : Boleite::GUI
  @app : Boleite::Application
  @world : World

  getter window

  def initialize(@gui, @app, @world)
    target_size = @gui.target_size

    @window = Boleite::GUI::Window.new
    @window.header_text = "Menu"

    container = Boleite::GUI::Layout.new :vertical
    button = Boleite::GUI::Button.new "Continue", Boleite::Vector2f.new(200.0, 20.0)
    button.click.on { hide }
    container.add button
    button = Boleite::GUI::Button.new "Save & Quit", Boleite::Vector2f.new(200.0, 20.0)
    button.click.on { save; quit }

    container.add button

    @window.add container

    window_size = @window.size
    @window.position = Boleite::Vector2f.new target_size.x / 2 - window_size.x / 2, target_size.y / 2 - window_size.y / 2
    @window.visible = false
  end

  def show
    @window.visible = true
    @gui.each_root { |root| root.enabled = false }
    @window.enabled = true 
  end

  def hide
    @window.visible = false
    @gui.each_root { |root| root.enabled = true }
  end

  def save
    SaveGameHelper.save @world
  end

  def quit
    state = @app.state_stack.pop
  end
end