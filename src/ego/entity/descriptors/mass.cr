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
    MassDescriptor.get_weight_str weight
  end

  def get_volume_str(mass)
    volume = mass.volume
    MassDescriptor.get_volume_str volume
  end

  def self.get_weight_str(weight)
    if weight < 1
      "#{weight*1000}g"
    else
      "#{weight}kg"
    end
  end

  def self.get_volume_str(volume)
    "#{volume}l"
  end
end