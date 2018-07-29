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

  def create
    unit = SocialUnit.new @id_generator.generate
    add unit
    unit
  end

  def update(world)
    @instances.each do |i|
      i.update world
    end
  end
end