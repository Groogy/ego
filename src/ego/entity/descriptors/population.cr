class PopulationDescriptor < EntityDescriptor
  def applies_to?(tmpl)
    tmpl.has_component? PopulationComponent
  end

  def apply(entity, world, data)
    comp = entity.get_component PopulationComponent
    "#{comp.population} people live here. The #{entity.template.name} can support #{comp.max_population}."
  end
end