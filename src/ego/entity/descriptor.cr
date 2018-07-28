abstract class EntityDescriptor
  abstract def applies_to?(tmpl : EntityTemplate) : Bool
  abstract def apply(entity : Entity, world : World, data : Inspector::DescriptorData) : String?

  def priority : Int32
    0
  end
end