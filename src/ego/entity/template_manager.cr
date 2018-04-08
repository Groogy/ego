class EntityTemplateManager
  include CrystalClear

  class LoadedData < Hash(String, EntityTemplateData)
  end

  @templates = {} of String => EntityTemplate

  requires Dir.exists? path
  def load_folder(path)
    loaded_data = LoadedData.new
    Dir.each_child path do |file|
      loaded_data.merge! load_file(path + File::SEPARATOR + file, false)
    end
    post_load loaded_data
  end

  requires File.exists? path
  def load_file(path, do_post = true)
    loaded_data = LoadedData.new
    File.open(path, "r") do |file|
      serializer = Boleite::Serializer.new nil
      data = serializer.read(file)
      templates = serializer.unmarshal(data, LoadedData)
      assert templates
      loaded_data = templates if templates
    end
    post_load loaded_data if do_post
    loaded_data
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

  private def post_load(loaded_data)
    builders = [] of EntityTemplate::Builder
    loaded_data.each do |key, value|
      tmpl = EntityTemplate.new value
      @templates[key] = tmpl
      builders << EntityTemplate::Builder.new tmpl
    end

    builders.each do |builder|
      builder.post_load self
    end
  end
end