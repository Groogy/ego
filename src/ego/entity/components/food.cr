class FoodComponent < EntityComponent
  include CrystalClear

  def hunger_worth
    hunger_worth data
  end

  def self.hunger_worth(data)
    data.get_int "hunger_worth"
  end
end
