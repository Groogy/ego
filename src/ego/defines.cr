require "./defines_def.cr"

module Defines
  define_value world_size, Int64, 1024

  # World Generation
  define_value generator_noise_scale, Float64, 1.0
  define_value generator_start_average_temperature, Float64, 0.0
  define_value generator_start_temperature_volatility, Float64, 0.0
  define_value generator_start_water_level, Float64, 0.0
  define_value generator_start_max_height, Float64, 128.0
  define_value generator_start_fertility, Float64, 0.0
  define_value generator_start_terrain, String, ""
end
