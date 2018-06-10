class EntityComponentData
  include CrystalClear

  alias DataType = Bool | Int64 | Float64 | String | Hash(String, DataType) | Array(DataType) | GameTime

  @id : String
  @data : Hash(String, DataType)

  getter id, data

  def initialize(@id, @data)
    convert_gametime_data
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

  requires @data.has_key? key
  requires @data[key].is_a? Array(DataType)
  def get_array(key)
    @data[key].as(Array(DataType))
  end

  requires @data.has_key? key
  requires @data[key].is_a? Hash(String, DataType)
  def get_hash(key)
    @data[key].as(Hash(String, DataType))
  end

  requires @data.has_key? key
  requires @data[key].is_a? GameTime
  def get_gametime(key)
    @data[key].as(GameTime)
  end

  private def convert_gametime_data
    @data.each do |key, value|
      if value.is_a? Hash(String, DataType)
        hsh = {} of String => Int64
        value.each do |k, v|
          hsh[k] = v.as(Int64)
        end
        begin
          time = GameTime.new hsh
        rescue ArgumentError
        else
          @data[key] = time
        end
      end
    end
  end
end
