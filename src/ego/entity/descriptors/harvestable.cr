class HarvestableDescriptor < EntityDescriptor
  def applies_to?(tmpl)
    tmpl.has_component? HarvestableComponent
  end

  def apply(entity, world, data)
    harvestable = entity.get_component HarvestableComponent
    if harvestable.empty?
      "#{entity.template.name} has nothing to harvest."
    else
      generate_content_buttons entity, harvestable, data
      count = harvestable.count
      "Has #{count} #{count > 1 ? "items" : "item"} to harvest."
    end
  end

  def generate_content_buttons(entity, harvestable, data)
    button = Boleite::GUI::Button.new "Harvest", Inspector::ENTITY_ENTRY_SIZE
    button.click.on { open_content_window entity, harvestable, data }
    data.container.add button
  end

  def open_content_window(entity, harvestable, data)
    window = data.inspector.open_window
    window.header_text = "#{entity.template.name} Harvest"
    layout = Boleite::GUI::Layout.new :vertical
    layout.padding = Boleite::Vector2f.new 1.0, 1.0
    window.pulse.on do
      layout.clear
      harvestable.each do |item|
        button = Boleite::GUI::Button.new item.template.name, Inspector::ENTITY_ENTRY_SIZE
        button.click.on { data.inspector.open_entity item ; Nil }
        layout.add button
      end
    end
    window.add layout
  end
end