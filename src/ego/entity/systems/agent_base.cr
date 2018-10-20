abstract class AgentBaseSystem < EntitySystem
  include CrystalClear

  requires !component.home.nil?
  def go_home(world, entity, component, moving)
    if home = component.home
      path = PathFinder.quick_search world, entity.position.point, home
      assert path
      moving.target = path
    end
  end
end
