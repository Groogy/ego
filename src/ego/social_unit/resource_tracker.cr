class SocialUnitResourceTracker
  class Area
    include CrystalClear

    @resource : EntityTemplate
    @tiles = [] of Map::Pos
    @quantity = 0
    @last_prospect : GameTime

    getter resource, tiles, last_prospect
    property quantity

    def initialize(@resource, pos, @last_prospect)
      @tiles << pos
    end

    def initialize(@resource, @tiles, @quantity, @last_prospect)
    end

    def add(entity, world)
      @last_prospect = world.current_tick
      add_quantity entity
      pos = entity.position.point
      @tiles << pos unless @tiles.includes? pos
    end

    def add_quantity(entity)
      comp = entity[SurveyorInterestComponent]
      if key = comp.quantity_container
        container = entity.get_component(key).as(BaseStorageComponent)
        @quantity += container.count { |e| e.has_component? SurveyorInterestComponent }
      else
        @quantity += 1
      end
    end

    def outdated?(world)
      date = @last_prospect
      date.add_days 5
      world.current_tick > date
    end

    def contains?(pos)
      @tiles.includes? pos
    end

    def each_entity(grid : EntityGrid)
      @tiles.each do |t|
        grid.each_at t do |e|
          yield e if e.template == @resource
        end
      end
    end

    def any_entity?(grid : EntityGrid)
      each_entity grid do |e|
        return true if yield e
      end
      return false
    end

    invariant @quantity >= 0
  end

   @areas = [] of Area

   protected property areas

   def register(entity, world)
    area = find_valid_area entity, world
    area.add entity, world
   end

   def update(world)
    @areas.reject! { |a| a.outdated? world }
   end

   def contains?(pos, tmpl)
    @areas.any? { |a| a.resource == tmpl && a.contains? pos }
   end

   def find_valid_area(entity, world)
    find_valid_area entity.position.point, entity.template, world
   end

   def find_valid_area(pos, tmpl, world)
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

   def each_area
    @areas.each { |e| yield e }
   end
end