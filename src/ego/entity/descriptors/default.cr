class DefaultEntityDescriptor < EntityDescriptor
  def applies_to?(tmpl)
    !tmpl.description.empty?
  end

  def apply(entity, window)
    desc = Boleite::GUI::TextBox.new entity.template.description, Inspector::ENTITY_INFO_SIZE
    desc.character_size = 12u32
    window.add desc
  end

  def priority
    100 # We want this text first
  end
end