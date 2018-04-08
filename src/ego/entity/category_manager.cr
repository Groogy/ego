class EntityCategoryManager
  include CrystalClear

  @categories = {} of String => EntityCategory

  def initialize
  end
  
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
      categories = serializer.unmarshal data, Hash(String, EntityCategory)
      assert categories
      @categories.merge! categories if categories
    end
  end

  requires @categories.has_key? key
  def get_category(key)
    @categories[key]
  end

  def each_category
    @categories.each do |key, value|
      yield key, value
    end
  end
end