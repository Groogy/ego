class EntityManager
  include CrystalClear

  @grid : EntityGrid
  @entities = [] of Entity

  def initialize(size)
    @grid = EntityGrid.new size
  end

  def create_entity(tmpl, pos)
    entity = Entity.new tmpl, pos
    @grid.add entity
    @entities << entity
    puts "Created #{entity} at #{entity.position}"
    entity
  end
end