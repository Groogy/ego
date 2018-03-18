class GameStateRenderHelper
  delegate :clear, :draw, present, to: @renderer

  getter renderer, camera3d, camera2d
  
  def initialize(gfx)
    target = gfx.main_target
    @camera3d = Boleite::Camera3D.new(60.0f32, target.width.to_f32, target.height.to_f32, 0.01f32, 100.0f32)
    @camera2d = Boleite::Camera2D.new(target.width.to_f32, target.height.to_f32, 0f32, 1f32)
    shader = Boleite::Shader.load_file "test.shader", gfx
    @renderer = Boleite::ForwardRenderer.new gfx, @camera3d, shader
    @camera3d.move 0.0, 8.0, -2.5
  end

  def set_2d_camera
    @renderer.camera = @camera2d
  end

  def set_3d_camera
    @renderer.camera = @camera3d
  end
end