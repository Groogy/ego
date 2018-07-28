class ControlMenu
  include CrystalClear

  MIN_SPEED = 1
  MAX_SPEED = 5

  @world : World
  @speed = MIN_SPEED

  invariant @speed >= MIN_SPEED
  invariant @speed <= MAX_SPEED

  getter window, speed

  def initialize(@world)
    @window = Boleite::GUI::Window.new
    @window.header_text = "Control"
    @window.position = Boleite::Vector2f.new 0.0, @window.header_size

    window_container = Boleite::GUI::Layout.new Boleite::GUI::Layout::Style::Vertical
    container = Boleite::GUI::Layout.new Boleite::GUI::Layout::Style::Horizontal
    @pause_button = Boleite::GUI::Button.new "Pause", Boleite::Vector2f.new(100.0, 20.0)
    @pause_button.click.on &->on_toggle_pause(Boleite::Vector2f)
    container.add @pause_button

    date = @world.date
    @date_label = Boleite::GUI::Label.new date.to_formated_string, Boleite::Vector2f.new(200.0, 20.0)
    @date_label.character_size = 12u32
    container.add @date_label
    window_container.add container

    container = Boleite::GUI::Layout.new Boleite::GUI::Layout::Style::Horizontal
    tmp = Boleite::GUI::Label.new "Speed:", Boleite::Vector2f.new(50.0, 20.0)
    tmp.character_size = 14u32
    container.add tmp
    @speed_label = Boleite::GUI::Label.new @speed.to_s, Boleite::Vector2f.new(30.0, 20.0);
    @speed_label.character_size = 14u32
    container.add @speed_label

    button = Boleite::GUI::Button.new "-", Boleite::Vector2f.new(20.0, 20.0);
    button.label.character_size = 14u32
    button.click.on { decrease_speed }
    container.add button
    button = Boleite::GUI::Button.new "+", Boleite::Vector2f.new(20.0, 20.0);
    button.label.character_size = 14u32
    button.click.on { increase_speed }
    container.add button
    window_container.add container

    @window.add window_container
  end

  def increase_speed
    @speed += 1 if @speed < MAX_SPEED
    @speed_label.text = @speed.to_s
  end

  def decrease_speed
    @speed -= 1 if @speed > MIN_SPEED
    @speed_label.text = @speed.to_s
  end

  def speed_modifier
    if @speed == MAX_SPEED
      0.0
    else
      1.0 / @speed ** @speed
    end
  end

  def max_speed?
    @speed == MAX_SPEED
  end

  def update
    if @world.paused?
      @pause_button.label_text = "Unpause"
    else
      @pause_button.label_text = "Pause"
    end
    @date_label.text = @world.date.to_formated_string
  end

  def on_toggle_pause(pos : Boleite::Vector2f)
    @world.toggle_pause
    update
  end
end