class DefaultEntityDescriptor < EntityDescriptor
  def applies_to?(tmpl)
    !tmpl.description.empty?
  end

  def apply(entity, world, data)
    entity.template.description
  end

  def priority
    -1 # We want this text first
  end
end