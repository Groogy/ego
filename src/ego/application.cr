class EgoApplication < Boleite::Application
  CONFIGURATION_FILE = "config.yml"
  
  def create_configuration : Boleite::Configuration
    if File.exists? CONFIGURATION_FILE
      File.open(CONFIGURATION_FILE, "r") do |file|
        serializer = Boleite::Serializer.new
        data = serializer.read(file)
        config = serializer.unmarshal(data, AppConfiguration)
        config.as(AppConfiguration)
      end
    else
      File.open(CONFIGURATION_FILE, "w") do |file|
        config = AppConfiguration.new 
        serializer = Boleite::Serializer.new
        serializer.marshal(config)
        serializer.dump(file)
        config
      end
    end
  end
end