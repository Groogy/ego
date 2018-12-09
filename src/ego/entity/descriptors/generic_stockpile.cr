class GenericStockpileDescriptor < EntityDescriptor
  def applies_to?(tmpl)
    tmpl.has_component? GenericStockpileComponent
  end

  def apply(entity, world, data)
    stockpile = entity.get_component GenericStockpileComponent
    unless stockpile.empty?
      generate_content_buttons entity, stockpile, data
    end
    generate_str stockpile, world
  end

  def generate_str(stockpile, world)
    volume = MassDescriptor.get_volume_str stockpile.calculate_volume
    max_volume = MassDescriptor.get_volume_str stockpile.max_volume
    categories = stockpile.get_allowed_categories world
    str = "Storing #{volume} of maximum #{max_volume}. "
    str += "Can store #{categories.join(",") { |c| c.name }}."
    str
  end

  def generate_content_buttons(entity, stockpile, data)
    button = Boleite::GUI::Button.new "Stockpile", Inspector::ENTITY_ENTRY_SIZE
    button.click.on { open_content_window entity, stockpile, data }
    data.container.add button
  end

  def open_content_window(entity, stockpile, data)
    window = data.inspector.open_window
    window.header_text = "#{entity.template.name} Stockpile"
    layout = Boleite::GUI::Layout.new :vertical
    layout.padding = Boleite::Vector2f.new 1.0, 1.0
    window.pulse.on do
      layout.clear
      stockpile.each do |item|
        button = Boleite::GUI::Button.new item.template.name, Inspector::ENTITY_ENTRY_SIZE
        button.click.on { data.inspector.open_entity item ; Nil }
        layout.add button
      end
    end
    window.add layout
  end
end