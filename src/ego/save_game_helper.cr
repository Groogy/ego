require "zip"

struct SaveGameHelper
  class Exception < Exception
  end

  DEFAULT_PATH = "saves"
  DEFAULT_SAVE_FILE = DEFAULT_PATH + "/default.zip"
  GAME_STATE_FILE = "gamestate.yml"
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
      zipper.each_entry do |file|
        case file.filename
        when GAME_STATE_FILE then world = read_game_state file.io
        when MAP_DATA_FILE then map_data = read_map_data file.io
        end
      end
      if world && map_data
        world.map.apply_data map_data, world.terrains
        world
      else
        raise Exception.new "Corrupt save file '#{DEFAULT_SAVE_FILE}''"
      end
    end
  end

  def self.save(world)
    ensure_path
    game_state = write_game_state world
    map_data = write_map_data world
    zip_save game_state, map_data
  end 

  def self.read_game_state(file)
    serializer = Boleite::Serializer.new nil
    data = serializer.read file
    tmp = serializer.unmarshal data, World
    tmp.as(World)
  end

  def self.read_map_data(file)
    serializer = Map::ObjSerializer.new
    terrain_list = serializer.read_terrain_list file
    map_data = serializer.read_map_data file
    map_data.map do |raw|
      { raw[0], terrain_list[raw[1]], raw[2] }
    end
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

  def self.zip_save(game_state, map_data)
    Zip::Writer.open DEFAULT_SAVE_FILE do |zipper|
      zipper.add GAME_STATE_FILE, game_state
      zipper.add MAP_DATA_FILE, map_data
    end
  end
end