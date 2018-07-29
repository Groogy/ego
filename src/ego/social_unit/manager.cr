class SocialUnitManager
  include CrystalClear

  @instances = [] of SocialUnit
  @id_generator : IdGenerator

  delegate each, each_with_index, to: @instances
  protected property instances, id_generator

  def initialize(@id_generator = IdGenerator.new)
  end

  requires !@instances.includes? unit
  def add(unit)
    @instances << unit
  end
end