class NameGenerator
  include CrystalClear

  alias List = Array(String)

  @lists = {} of String => List
  @builders = [] of NameBuilder

  def initialize(@lists, @builders)
  end

  requires !@builders.empty?
  def generate(random)
    builder = pick_builder random
    builder.generate @lists, random
  end

  def pick_builder(random)
    index = random.get_int 0, @builders.size
    @builders[index]
  end
end