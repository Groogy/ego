alias EntityId = Int64

class EntityIdGenerator
  @next_id : Int64

  def initialize(@next_id = 1i64)
  end

  def peak_next
    @next_id
  end

  def generate
    id = @next_id
    @next_id += 1i64
    id
  end
end
