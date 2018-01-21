class TerrainType
end

class TerrainDatabase
  include CrystalClear

  class Collection < Hash(String, TerrainType)
  end

  @types = Collection.new

  requires File.exists? path
  def load_file(path)
    File.open(path, "r") do |file|
      serializer = Boleite::Serializer.new
      data = serializer.read(file)
      types = serializer.unmarshal(data, Collection)
      assert types
      @types.merge! types if types
    end
  end

  requires @types.has_key? key
  def find(key)
    @types[key]
  end
end