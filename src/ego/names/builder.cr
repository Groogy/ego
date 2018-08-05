class NameBuilder
  struct Entry
    getter key : String
    getter text : String
    getter can_follow : Array(String)
    getter? use_list : Bool
    getter? start_piece : Bool

    def initialize(@key, @text, @can_follow, @use_list, @start_piece)
    end

    def potential?(previous)
      return true if start_piece? && previous.nil?
      return false if previous.nil?
      return true if @can_follow.any? { |key| key == previous.key }
      return false
    end

    def generate(lists, random)
      if use_list?
        assert lists.has_key? @text
        list = lists[@text]
        index = random.get_int 0, list.size 
        list[index]
      else
        @text
      end
    end
  end

  @entries = [] of Entry

  def initialize(@entries)
  end

  def generate(lists, random)
    name = ""
    previous = nil
    loop do
      result, previous = generate_piece previous, lists, random
      name += " " unless name.empty? || result.empty?
      name += result
      break if result.empty?
    end
    name
  end

  def generate_piece(previous, lists, random)
    potentials = find_potential_entries previous
    return {"", previous} if potentials.empty?
    index = random.get_int 0, potentials.size
    entry = potentials[index]
    return {entry.generate(lists, random), entry}
  end

  def find_potential_entries(previous)
    @entries.compact_map do |entry|
      entry if entry.potential? previous
    end
  end
end