class SurveyorInterestComponent < EntityComponent
  def quantity_container
    if @data.has_key? "quantity_container"
      @data.get_string "quantity_container"
    else
      nil
    end
  end
end
