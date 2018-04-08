class EntityTemplateManager
  include CrystalClear

  @templates = {} of String => EntityTemplate

  requires Dir.exists? path
  def load_folder(path, world)
    loaded_data = {} of String => EntityTemplateData
    Dir.each_child path do |file|
      loaded_data.merge! load_file(path + File::SEPARATOR + file, world, false)
    end
    post_load loaded_data, world
  end

  requires File.exists? path
  def load_file(path, world, do_post = true)
    loaded_data = {} of String => EntityTemplateData
    File.open(path, "r") do |file|
      serializer = Boleite::Serializer.new nil
      data = serializer.read(file)
      templates = serializer.unmarshal data, Hash(String, EntityTemplateData)
      assert templates
      loaded_data = templates if templates
    end
    post_load loaded_data, world if do_post
    loaded_data
  end

  requires @templates.has_key? key
  def get_template(key)
    @templates[key]
  end

  def each_template
    @templates.each do |key, value|
      yield key, value
    end
  end

  private def post_load(loaded_data, world)
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