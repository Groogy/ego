class NameGeneratorManager
  include CrystalClear

  @generators = [] of NameGenerator

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
      data = serializer.read file
      generator = serializer.unmarshal data, NameGenerator
      assert generator
      @generators << generator if generator
    end
  end

  def generate(world)
    random = world.random
    generator = pick_generator random
    generator.generate random
  end

  def pick_generator(random)
    index = random.get_int 0, @generators.size
    @generators[index]
  end
end