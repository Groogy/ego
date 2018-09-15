class SocialUnitResourceTracker
  class Area
    @resource : EntityTemplate
    @tiles = [] of Map::Pos
    @quantity = 0
    @last_prospect : GameTime

    getter resource
    property quantity

    def initialize(@resource, pos, @last_prospect)
      @tiles << pos
    end

    def add(entity, world)
      @last_prospect = world.current_tick
      @quantity += 1
      pos = entity.position.point
      @tiles << pos unless @tiles.includes? pos
    end

    def outdated?(world)
      date = @last_prospect
      date.add_days 5
      world.current_tick > date
    end

    def contains?(pos)
      @tiles.includes? pos
    end
  end

   @areas = [] of Area

   def register(entity, world)
    area = find_area entity, world
    area.add entity, world
   end

   def update(world)
    @areas.reject! { |a| a.outdated? world }
   end

   def contains?(pos, tmpl)
    @areas.any? { |a| a.resource == tmpl && a.contains? pos }
   end

   def find_area(entity, world)
    find_area entity.position.point, entity.template, world
   end

   def find_area(pos, tmpl, world)
    directions = {
      Boleite::Vector2i.new(0, 0),
      Boleite::Vector2i.new(1, 0), Boleite::Vector2i.new(-1, 0),
      Boleite::Vector2i.new(0, 1), Boleite::Vector2i.new(0, -1),
    }
    @areas.each do |a|
      next if a.resource != tmpl
      directions.each do |dir|
        return a if a.contains? pos + dir
      end
    end

    @areas << Area.new tmpl, pos, world.current_tick
    @areas.last
   end
end