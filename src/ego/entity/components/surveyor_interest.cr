class SurveyorInterestComponent < EntityComponent
  def quantity_container
    SurveyorInterestComponent.quantity_container @data
  end

  def outdated_time
    SurveyorInterestComponent.outdated_time @data
  end

  def self.quantity_container(data)
    if data.has_key? "quantity_container"
      data.get_string "quantity_container"
    else
      nil
    end
  end

  def self.outdated_time(data)
    data.get_gametime "outdated"
  end
end
