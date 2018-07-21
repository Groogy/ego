struct EntityGraphicsTemplate
  @uv = Boleite::Vector2u.zero

  getter uv

  def initialize()
  end

  def initialize(@uv)
  end
end