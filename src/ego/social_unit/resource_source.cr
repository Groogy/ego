abstract class ResourceSource
  abstract def gather(social_unit, world)
end

abstract class FoodSource < ResourceSource
  include CrystalClear

  Contracts.ignore_method initialize
  Contracts.ignore_method score

  @area : Array(Map::Pos)
  @resource : EntityTemplate
  @quantity : Int32

  def initialize(@area, @resource, @quantity)
  end

  def food_hunger_worth
    data = @resource.get_component_data FoodComponent.id
    FoodComponent.hunger_worth data
  end

  abstract def score : Int32

  invariant @resource.has_component? FoodSourceComponent
  invariant @resource.has_component? FoodComponent
end

class PickupFoodSource < FoodSource
  def gather(social_unit, world)
  end

  def score
    @quantity * food_hunger_worth
  end
end

class HarvestableFoodSource < FoodSource
  def gather(social_unit, world)
    puts "HELLO! #{@resource.id} #{@quantity}"
  end

  def harvesting_difficulty
    data = @resource.get_component_data HarvestableComponent.id
    HarvestableComponent.difficulty data
  end

  def score
    (@quantity * food_hunger_worth) / harvesting_difficulty
  end

  invariant @resource.has_component? HarvestableComponent
end