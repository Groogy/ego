class CarrierComponent < BaseStorageComponent
  include CrystalClear

  def max_volume
    @data.get_float "max_volume"
  end

  def max_weight
    @data.get_float "max_weight"
  end

  def can_store?(storage, entity : Entity)
    can_store? storage, entity.template
  end
  
  def can_store?(storage, tmpl : EntityTemplate)
    calculate_volume_with(tmpl) < max_volume && calculate_weight_with(tmpl) < max_weight
  end

  def can_take?(storage, entity, taker)
    taker == storage
  end
end
