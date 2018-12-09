class HungerComponent < EntityComponent
  include CrystalClear

  @satisfaction : Int64

  property satisfaction

  def initialize(data, entity, world)
    super data, entity, world
    @satisfaction = data.get_int "max_satisfaction"
  end

  def satisfaction_decay
    @data.get_int "satisfaction_decay"
  end

  def max_satisfaction
    @data.get_int "max_satisfaction"
  end

  def hunger_ratio
    satisfaction.to_f / max_satisfaction.to_f 
  end

  def want_food?
    hunger_ratio < 0.9
  end

  def edible
    @data.get_array("edible").map { |val| val.as(String) }
  end

  def is_edible?(entity)
    tmpl = entity.template
    edible.any? { |cat| tmpl.has_category? cat }
  end

  requires food.has_component? FoodComponent
  requires is_edible? food
  def eat(food)
    comp = food.get_component FoodComponent
    worth = comp.hunger_worth
    @satisfaction += worth
    @satisfaction = {@satisfaction, max_satisfaction}.min
    food.destroy
  end
end
