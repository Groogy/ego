class EntityCategory
  @id : String
  @name : String
  @visible : Bool

  getter id, name
  getter? visible

  def initialize(@id, @name, @visible)
  end
end