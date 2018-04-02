class TerrainType
end

class TerrainDatabase
  include CrystalClear

  class Collection < Hash(String, TerrainType)
  end

  @types = Collection.new

  requires Dir.exists? path
  def load_folder(path)
    Dir.each_child path do |file|
      load_file path + File::SEPARATOR + file
    end
  end

  requires File.exists? path
  def load_file(path)
    File.open(path, "r") do |file|
      serializer = Boleite::Serializer.new nil
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

  def each_type
    @types.each do |key, value|
      yield key, value
    end
  end
end