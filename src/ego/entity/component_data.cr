class EntityComponentData
  include CrystalClear

  alias DataType = Bool | Int64 | Float64 | String | Hash(String, DataType) | Array(DataType)

  @id : String
  @data : Hash(String, DataType)

  getter id, data

  def initialize(@id, @data)
  end

  requires @data.has_key? key
  requires @data[key].is_a? String
  def get_string(key)
    @data[key].as(String)
  end

  requires @data.has_key? key
  requires @data[key].is_a? Int64
  def get_int(key)
    @data[key].as(Int64)
  end

  requires @data.has_key? key
  requires @data[key].is_a? Float64
  def get_float(key)
    @data[key].as(Float64)
  end

  requires @data.has_key? key
  requires @data[key].is_a? Bool
  def get_bool(key)
    @data[key].as(Bool)
  end
end