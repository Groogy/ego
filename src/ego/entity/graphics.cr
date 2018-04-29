struct EntityGraphicsTemplate
  @uv = Boleite::Vector2u.zero
  @height = UInt16.zero

  getter uv, height

  def initialize()
  end

  def initialize(@uv, @height)
  end
end