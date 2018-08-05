class NameGenerator
  struct Serializer
    def unmarshal(node)
      builders = node.unmarshal "name_builders", Array(NameBuilder)
      lists = {} of String => List
      node.each do |key, value|
        key = key.to_s
        next if key == "name_builders"
        lists[key] = node.unmarshal key, Array(String)
      end
      NameGenerator.new lists, builders
    end
  end

  extend Boleite::Serializable(Serializer)
end