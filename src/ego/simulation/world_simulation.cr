abstract class WorldSimulation
  abstract def update(world)
end

class NullWorldSimulation < WorldSimulation
  def update(world)
    # Do nothing
  end
end