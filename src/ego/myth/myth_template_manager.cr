class MythTemplateManager
  include CrystalClear

  @templates = {} of String => MythTemplate

  requires Dir.exists? path
  def load_folder(path)
    loaded_data = {} of String => MythTemplateData
    Dir.each_child path do |file|
      loaded_data.merge! load_file(path + File::SEPARATOR + file, false)
    end
    post_load loaded_data
  end

  requires File.exists? path
  def load_file(path, do_post = true)
    loaded_data = {} of String => MythTemplateData
    File.open(path, "r") do |file|
      serializer = Boleite::Serializer.new nil
      data = serializer.read(file)
      templates = serializer.unmarshal data, Hash(String, MythTemplateData)
      assert templates
      loaded_data = templates if templates
    end
    post_load loaded_data if do_post
    loaded_data
  end

  def count
    @templates.size
  end

  requires @templates.has_key? key
  def get(key)
    @templates[key]
  end

  def get_all_of(type : MythTemplate::Type)
    hsh = @templates.select { |k,v| v.type == type }
    hsh.values
  end

  def has?(key)
    @templates.has_key? key
  end

  def each
    @templates.each do |key, value|
      yield key, value
    end
  end

  private def post_load(loaded_data)
    loaded_data.each do |key, value|
      tmpl = MythTemplate.new value
      @templates[key] = tmpl
    end
  end
end