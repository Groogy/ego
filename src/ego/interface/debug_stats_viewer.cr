class DebugStatsViewer
  @world : World

  getter :window

  def initialize(target_size, @world)
    @window = Boleite::GUI::Window.new
    @window.position = Boleite::Vector2f.new target_size.x - 200.0, 20.0
    @window.header_text = "Debug Statistics"

    container = Boleite::GUI::Layout.new :vertical
    @info = Boleite::GUI::TextBox.new "", Boleite::Vector2f.new(200.0, 100.0)
    @info.character_size = 14u32
    container.add @info
    @window.add container

    @profiler = Profiler.new
  end

  def update(full_update)
    @profiler.tick
    if full_update
      apply_text
    end
  end

  def apply_text
    text = ""
    text += "#{@profiler.num_ticks_per_second} / Ticks Per Second\n"
    text += "#{@profiler.milliseconds_per_tick}ms / Ticks\n"

    @info.text = text
  end
end