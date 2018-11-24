class FoodSourceComponent < EntityComponent
  include CrystalClear

  def self.create_source(area)
    tmpl = area.resource
    case get_type tmpl
    when "harvestable"
      create_harvestable_source area
    else
      raise "Unknown Food Source Type referenced in #{tmpl.id}"
    end
  end

  def self.get_type(tmpl)
    data = tmpl.get_component_data "food_source"
    data.get_string "type"
  end

  def self.create_harvestable_source(area)
    HarvestableFoodSource.new area.tiles.dup, area.resource, area.quantity
  end
end
