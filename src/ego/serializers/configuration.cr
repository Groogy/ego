class AppConfiguration
  struct Serializer
    def marshal(obj, node)
      node.marshal("foobar", obj.foobar)
    end

    def unmarshal(node)
      config = AppConfiguration.new
      config.foobar = node.unmarshal_string("foobar")
      config
    end
  end

  extend Boleite::Serializable(Serializer)
end