class WorldGenerator
  @available_myths = [] of MythTemplate
  @myths = [] of Myth

  def initialize
    @world = World.new
    @world.load_data

    find_available_myths
  end

  def each_available_myth
    @available_myths.each do |m|
      yield m
    end
  end

  def select_myth(template)
    @myths << Myth.new template
    find_available_myths
  end

  def find_available_myths
    templates = @world.myth_templates
    if @myths.empty?
      @available_myths = templates.get_all_of MythTemplate::Type::CreationStart
    else
      @available_myths = templates.find_valid_for @myths
    end
  end

  def create_story
    @myths.join ", " { |m| m.template.text }
  end
end