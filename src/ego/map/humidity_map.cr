class ValueMap
end

class HumidityMap < ValueMap
  include CrystalClear

  def initialize(size : Boleite::Vector2u)
    super 0f32, size
  end

  requires value >= 0f32
  requires value <= 1f32
  def set_value(index : Int, value)
    super index, value
  end
end