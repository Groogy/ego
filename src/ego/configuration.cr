class AppConfiguration < Boleite::Configuration
  property :backend
  
  @backend = Boleite::BackendConfiguration.new
end