abstract class EntityDescriptor
  abstract def applies_to?(tmpl : EntityTemplate) : Bool
  abstract def apply(entity : Entity, window : Boleite::GUI::Window)
end