class Toolbox
  class InputHandler < Boleite::InputReceiver

  end
  @world : World
  @camera : Boleite::Camera2D
  @current_tool : ToolBase?
  @input = Boleite::InputReceiver.new

  getter window

  def initialize(@world, @camera)
    @window = Boleite::GUI::Window.new
    @window.header_text = "Toolbox"
    @window.position = Boleite::Vector2f.new(0.0, 95.0)

    container = Boleite::GUI::Layout.new :vertical
    @selected_label = Boleite::GUI::Label.new "None", Boleite::Vector2f.new(210.0, 20.0)
    @selected_label.character_size = 14u32
    button = Boleite::GUI::Button.new "None", Boleite::Vector2f.new(210.0, 20.0)
    button.click.on { select_no_tool }
    container.add @selected_label
    container.add button

    label_and_content = Boleite::GUI::Layout.new :vertical
    terrain_box = Boleite::GUI::Layout.new :vertical
    terrain_box.padding = Boleite::Vector2f.new 6.0, 2.0
    create_terrain_tool terrain_box
    label_and_content.add Boleite::GUI::Label.new("TERRAIN", Boleite::Vector2f.new(200.0, 20.0))
    label_and_content.add terrain_box

    height_box = Boleite::GUI::Layout.new :vertical
    height_box.padding = Boleite::Vector2f.new 6.0, 2.0
    create_height_tool height_box
    label_and_content.add Boleite::GUI::Label.new("HEIGHT", Boleite::Vector2f.new(200.0, 20.0))
    label_and_content.add height_box

    spawn_box = Boleite::GUI::Layout.new :vertical
    spawn_box.padding = Boleite::Vector2f.new 6.0, 2.0
    create_spawn_tool spawn_box
    label_and_content.add Boleite::GUI::Label.new("SPAWN", Boleite::Vector2f.new(200.0, 20.0))
    label_and_content.add spawn_box

    container.add label_and_content
    @window.add container
  end

  def enable(app)
    app.input_router.register @input
    select_no_tool
  end

  def disable(app)
    select_no_tool
    app.input_router.unregister @input
  end

  def select_no_tool
    attach_tool nil
    update_tool_label
  end

  def select_terrain_tool(terrain)
    attach_tool TerrainTool.new terrain, @world, @camera
    update_tool_label
  end

  def select_height_tool(direction)
    attach_tool HeightTool.new direction.to_i8, @world, @camera
    update_tool_label
  end

  def select_spawn_tool(tmpl)
    attach_tool SpawnTool.new tmpl, @world, @camera
    update_tool_label
  end

  def attach_tool(tool : ToolBase?)
    if old_tool = @current_tool
      @input.unregister old_tool
    end
    @current_tool = tool
    if tool
      @input.register_instance tool, ->tool.on_screen_click(Boleite::Vector2f)
    end
  end

  def update_tool_label
    if tool = @current_tool
      @selected_label.text = tool.label
    else
      @selected_label.text = "None"
    end
  end

  def create_terrain_tool(container)
    terrains = @world.terrains
    current = Boleite::GUI::Layout.new :horizontal
    current.padding = Boleite::Vector2f.new 0.0, 0.0
    container.add current
    counter = 0
    terrains.each_type do |key, type|
      button = Boleite::GUI::Button.new type.name, Boleite::Vector2f.new(70.0, 20.0)
      button.click.on { select_terrain_tool type }
      current.add button
      counter += 1
      if counter >= 3
        current = Boleite::GUI::Layout.new :horizontal
        current.padding = Boleite::Vector2f.new 0.0, 0.0
        container.add current
        counter = 0
      end
    end
  end

  def create_height_tool(container)
    current = Boleite::GUI::Layout.new :horizontal
    current.padding = Boleite::Vector2f.new 0.0, 0.0
    button = Boleite::GUI::Button.new "Raise", Boleite::Vector2f.new(70.0, 20.0)
    button.click.on { select_height_tool 1 }
    current.add button
    button = Boleite::GUI::Button.new "Lower", Boleite::Vector2f.new(70.0, 20.0)
    button.click.on { select_height_tool -1 }
    current.add button
    container.add current
  end

  def create_spawn_tool(box)
    templates = @world.entity_templates
    containers = {} of EntityCategory => Boleite::GUI::Layout
    templates.each do |key, tmpl|
      category = tmpl.primary_category
      next if !category.visible?
      if !containers.keys.includes? category
        containers[category] = Boleite::GUI::Layout.new :horizontal
      end

      button = Boleite::GUI::Button.new tmpl.name, Boleite::Vector2f.new(80.0, 20.0)
      button.click.on { select_spawn_tool tmpl }
      containers[category].add button
    end

    containers.each do |category, container|
      label = Boleite::GUI::Label.new category.name, Boleite::Vector2f.new(200.0, 20.0)
      box.add label
      box.add container
    end
  end
end