class AppConfiguration
  struct Serializer
    def marshal(obj, node)
      node.marshal("backend", obj.backend)
    end

    def unmarshal(node)
      config = AppConfiguration.new
      config.backend = node.unmarshal("backend", Boleite::BackendConfiguration)
      config
    end
  end

  extend Boleite::Serializable(Serializer)
end