class FruitingDescriptor < EntityDescriptor
  def applies_to?(tmpl)
    tmpl.has_component? FruitingComponent
  end

  def apply(entity, world, container)
    text = generate_text entity, world
    desc = Boleite::GUI::TextBox.new text, Inspector::ENTITY_INFO_SIZE
    desc.character_size = 12u32
    container.add desc
  end

  def generate_text(entity, world)
    fruiting = entity.get_component FruitingComponent
    text = generate_seasonal_text fruiting
    text += generate_provides_text fruiting
    text += generate_growth_text fruiting, entity, world
    text
  end

  def generate_seasonal_text(fruiting)
    start = fruiting.start_season.to_month_in_year_named
    stop = fruiting.end_season.to_month_in_year_named
    "Seasonal period is #{start} to #{stop}. "
  end

  def generate_provides_text(fruiting)
    "Can provide #{fruiting.limit} #{fruiting.provides.name} at a time. "
  end

  def generate_growth_text(fruiting, entity, world)
    if fruiting.can_grow? entity, world
      days = fruiting.time_left.to_days
      "Currently growing another #{fruiting.provides.name} which will be ready in #{days}. "
    else
      "Is not growing any #{fruiting.provides.name} at the moment. "
    end
  end
end