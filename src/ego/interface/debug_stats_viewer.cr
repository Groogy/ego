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

    @frame_profiler = Profiler.new
    @tick_profiler = Profiler.new
  end

  def update(full_update)
    @frame_profiler.tick
    if full_update
      @tick_profiler.tick
      apply_text
    end
  end

  def fast_tick
    @tick_profiler.tick
  end

  def apply_text
    text = ""
    text += "#{@frame_profiler.num_ticks_per_second} / Frames Per Second\n"
    text += "#{@frame_profiler.milliseconds_per_tick}ms / Frame\n"
    text += "#{@tick_profiler.num_ticks_per_second} / Ticks Per Second\n"
    text += "#{@tick_profiler.milliseconds_per_tick}ms / Tick\n"

    @info.text = text
  end
end