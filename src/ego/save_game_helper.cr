struct SaveGameHelper
  DEFAULT_PATH = "saves"
  DEFAULT_SAVE_FILE = DEFAULT_PATH + "/default.yml"

  def self.ensure_path
    unless Dir.exists? DEFAULT_PATH
      Dir.mkdir DEFAULT_PATH
    end
  end

  def self.load
    ensure_path
    world = File.open(DEFAULT_SAVE_FILE, "r") do |file|
      serializer = Boleite::Serializer.new nil
      data = serializer.read(file)
      tmp = serializer.unmarshal(data, World)
      tmp.as(World)
    end
  end

  def self.save(world)
    ensure_path
    File.open(DEFAULT_SAVE_FILE, "w") do |file|
      serializer = Boleite::Serializer.new world
      serializer.marshal(world)
      serializer.dump(file)
    end
  end 
end