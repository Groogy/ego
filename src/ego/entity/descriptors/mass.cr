class MassDescriptor < EntityDescriptor
  def applies_to?(tmpl)
    tmpl.has_component? MassComponent
  end

  def apply(entity, world, data)
    mass = entity.get_component MassComponent
    weight = get_weight_str mass
    volume = get_volume_str mass
    "Weighs #{weight} and takes up #{volume}"
  end

  def get_weight_str(mass)
    weight = mass.weight
    if weight < 1
      "#{weight*1000}g"
    else
      "#{weight}kg"
    end
  end

  def get_volume_str(mass)
    volume = mass.volume
    "#{volume}l"
  end
end