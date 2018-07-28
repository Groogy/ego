class DefaultEntityDescriptor < EntityDescriptor
  def applies_to?(tmpl)
    !tmpl.description.empty?
  end

  def apply(entity, world, container)
    desc = Boleite::GUI::TextBox.new entity.template.description, Inspector::ENTITY_INFO_SIZE
    desc.character_size = 12u32
    container.add desc
  end

  def priority
    -1 # We want this text first
  end
end