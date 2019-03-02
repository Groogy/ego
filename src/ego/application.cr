class EgoApplication < Boleite::Application
  CONFIGURATION_FILE = "config.yml"
  
  def create_configuration : Boleite::Configuration
    if File.exists? CONFIGURATION_FILE
      File.open(CONFIGURATION_FILE, "r") do |file|
        serializer = Boleite::Serializer.new nil
        serializer.read(file)
        config = serializer.unmarshal(AppConfiguration)
        config.as(AppConfiguration)
      end
    else
      File.open(CONFIGURATION_FILE, "w") do |file|
        config = AppConfiguration.new 
        config.backend = @backend.default_config
        serializer = Boleite::Serializer.new nil
        serializer.marshal(config)
        serializer.dump(file)
        config
      end
    end
  end
end