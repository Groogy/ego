class NameGeneratorManager
  include CrystalClear

  @generators = [] of NameGenerator
  @history = [] of String

  protected property history

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
      serializer.read file
      generator = serializer.unmarshal NameGenerator
      assert generator
      @generators << generator if generator
    end
  end

  ensures !return_value.empty?
  def generate(world)
    random = world.random
    generator = pick_generator random
    name = ""
    loop do
      name = generator.generate random
      break if is_unique? name
    end
    @history << name
    name
  end

  def pick_generator(random)
    index = random.get_int 0, @generators.size
    @generators[index]
  end

  def is_unique?(name)
    !@history.includes? name
  end
end