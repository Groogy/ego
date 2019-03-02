require "zip"

struct SaveGameHelper
  class Exception < Exception
  end

  struct MetaData
    YAML.mapping(
      map_width: UInt32,
      map_height: UInt32,
    )

    def initialize
      @map_width = 0
      @map_height = 0
    end
  end

  DEFAULT_PATH = "saves"
  DEFAULT_SAVE_FILE = DEFAULT_PATH + "/default.zip"
  GAME_STATE_FILE = "gamestate.yml"
  META_FILE = "meta.yml"
  MAP_DATA_FILE = "map.data"

  def self.ensure_path
    unless Dir.exists? DEFAULT_PATH
      Dir.mkdir DEFAULT_PATH
    end
  end

  def self.load
    ensure_path
    Zip::Reader.open DEFAULT_SAVE_FILE do |zipper|
      world = nil
      map_data = nil
      meta_data = nil
      game_state_file = nil
      zipper.each_entry do |file|
        case file.filename
        when META_FILE then meta_data = MetaData.from_yaml file.io
        when GAME_STATE_FILE then game_state_file = file
        #when MAP_DATA_FILE then map_data = read_map_data file.io
        end
      end
      if game_state_file && meta_data
        world = read_game_state game_state_file.io, meta_data
      else
        raise "Corrupt save file '#{DEFAULT_SAVE_FILE}''"
      end
      if world && map_data
        #world.map.apply_data map_data, world.terrains
        world
      else
        raise "Corrupt save file '#{DEFAULT_SAVE_FILE}''"
      end
    end
  end

  def self.save(world)
    ensure_path
    game_state = write_game_state world
    map_data = write_map_data world
    meta_data = write_meta_data world
    zip_save game_state, map_data, meta_data
  end 

  def self.read_game_state(file, meta)
    pos = Boleite::Vector2u.new meta.map_width, meta.map_height
    world = World.new pos
    serializer = Boleite::Serializer.new world
    serializer.read file
    tmp = serializer.unmarshal World
    tmp.as(World)
  end

  def self.read_map_data(file)
    #serializer = Map::ObjSerializer.new
    #terrain_list = serializer.read_terrain_list file
    #map_data = serializer.read_map_data file
    #map_data.map do |raw|
    #  { raw[0], terrain_list[raw[1]], raw[2] }
    #end
    nil
  end

  def self.write_game_state(world)
    game_state = IO::Memory.new
    serializer = Boleite::Serializer.new world
    serializer.marshal world
    serializer.dump game_state
    game_state.rewind
    game_state
  end

  def self.write_map_data(world)
    map_data = IO::Memory.new
    serializer = Map::ObjSerializer.new
    terrain_list = serializer.write_terrain_list world, map_data
    serializer.write_map_data world.map.size, world.map.data, terrain_list, map_data
    map_data.rewind
    map_data
  end

  def self.write_meta_data(world)
    size = world.map.size
    io = IO::Memory.new
    data = MetaData.new
    data.map_width = size.x
    data.map_height = size.y
    data.to_yaml io
    io 
  end

  def self.zip_save(game_state, map_data, meta_data)
    Zip::Writer.open DEFAULT_SAVE_FILE do |zipper|
      zipper.add META_FILE, meta_data
      zipper.add GAME_STATE_FILE, game_state
      zipper.add MAP_DATA_FILE, map_data
    end
  end
end