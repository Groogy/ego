struct EntityGraphicsTemplate
  @uv = Boleite::Vector2u.zero
  @uv_size = Boleite::Vector2u.zero
  @height = UInt16.zero

  getter uv, uv_size, height

  def initialize()
  end

  def initialize(@uv, @uv_size, @height)
  end
end