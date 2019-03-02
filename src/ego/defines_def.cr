module Defines
  DEFINES_PATH = "data/defines.yml"

  struct Loader
    def initialize(@proc : Proc(Boleite::SerializableType, Nil))
    end

    def apply(v)
      @proc.call v.as(Boleite::SerializableType)
    end
  end

  @@loaders = {} of String => Loader

  macro define_value(name, type, default)
    @@{{name}} : {{type}} = {{default}}
    def self.{{name}} : {{type}}
      @@{{name}}
    end
    private def self.{{name}}=(@@{{name}})
    end
    @@loaders[{{name.stringify}}] = Loader.new ->(value : Boleite::SerializableType) { self.{{name}} = value.as({{type}}); nil }
  end

  def self.load
    File.open DEFINES_PATH, "r" do |f|
      serializer = Boleite::Serializer.new nil
      serializer.read f
      serializer.each do |k, v|
        @@loaders[k].apply v
      end
    end
  end
end