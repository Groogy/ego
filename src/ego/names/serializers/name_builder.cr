class NameBuilder
  struct Serializer
    def unmarshal(node)
      entries = [] of Entry
      node.each_child do |child|
        key = child.key.to_s
        text = child.unmarshal_string? "text", ""
        can_follow = child.unmarshal? "can_follow", Array(String), Array(String).new
        use_list = child.unmarshal_bool? "use_list", false
        start_piece = child.unmarshal_bool? "start_piece", false
        entries << Entry.new key, text, can_follow, use_list, start_piece
      end
      builder = NameBuilder.new entries
    end
  end

  extend Boleite::Serializable(Serializer)
end