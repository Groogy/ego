abstract class EntityDescriptor
  abstract def applies_to?(tmpl : EntityTemplate) : Bool
  abstract def apply(entity : Entity, world : World, container : Boleite::GUI::Container)

  def priority : Int32
    0
  end
end