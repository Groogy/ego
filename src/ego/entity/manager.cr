class EntityManager
  include CrystalClear

  @map : Map
  @grid : EntityGrid
  @entities = [] of Entity

  def initialize(@map)
    @grid = EntityGrid.new @map.size
  end

  def create_entity(tmpl, pos)
    entity = Entity.new tmpl, pos
    @grid.add entity
    @entities << entity
    puts "Created #{entity} at #{entity.position}"
    entity
  end
end