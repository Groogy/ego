class FoodComponent < EntityComponent
  include CrystalClear

  def hunger_worth
    @data.get_int "hunger_worth"
  end
end
