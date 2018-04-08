class EntityTemplateManager
  include CrystalClear

  class LoadedData < Hash(String, EntityTemplateData)
  end

  @loaded_data = LoadedData.new
  @templates = {} of String => EntityTemplate

  requires Dir.exists? path
  def load_folder(path)
    Dir.each_child path do |file|
      load_file path + File::SEPARATOR + file, false
    end
    post_load
  end

  requires File.exists? path
  def load_file(path, do_post = true)
    File.open(path, "r") do |file|
      serializer = Boleite::Serializer.new nil
      data = serializer.read(file)
      templates = serializer.unmarshal(data, LoadedData)
      assert templates
      @loaded_data.merge! templates if templates
    end
    post_load if do_post
  end

  requires @types.has_key? key
  def get_template(key)
    @templates[key]
  end

  def each_template
    @templates.each do |key, value|
      yield key, value
    end
  end

  private def post_load
    @loaded_data.each do |key, value|
      @templates[key] = EntityTemplate.new value
    end
    @loaded_data.clear
  end
end