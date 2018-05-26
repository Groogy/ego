class GameStateRenderHelper
  delegate :clear, :draw, present, to: @renderer

  getter renderer, camera
  
  def initialize(gfx)
    target = gfx.main_target
    @camera = Boleite::Camera2D.new(target.width.to_f32, target.height.to_f32, 0f32, 1f32)
    shader = Boleite::Shader.load_file "resources/shaders/test.shader", gfx
    @renderer = Boleite::ForwardRenderer.new gfx, @camera, shader
  end
end