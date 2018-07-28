class HarvestableDescriptor < EntityDescriptor
  def applies_to?(tmpl)
    tmpl.has_component? HarvestableComponent
  end

  def apply(entity, world, data)
    harvestable = entity.get_component HarvestableComponent
    if harvestable.empty?
      "#{entity.template.name} has nothing to harvest."
    else
      generate_content_buttons harvestable, data
    end
  end

  def generate_content_buttons(harvestable, data)
    harvestable.each do |item|
      button = Boleite::GUI::Button.new item.template.name, Inspector::ENTITY_ENTRY_SIZE
      button.click.on { data.inspector.open_entity item ; Nil }
      data.container.add button
    end
  end
end