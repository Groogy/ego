class GameState < Boleite::State
  class InputHandler < Boleite::InputReceiver
    def initialize(state)
      register Boleite::PassThroughAction, ->on_input(Boleite::InputEvent)
    end

    def on_input(event)
    end
  end

  @input : InputHandler | Nil
  
  def initialize(@app : EgoApplication)
    super()

    texture = Boleite::Texture.load_file "test.png", @app.graphics
    @sprite = Boleite::Sprite.new texture
    @sprite.position = Boleite::Vector2f.new 300.0, 300.0
    @sprite.origo = texture.size.to_f / 2.0
    @sprite.scale = Boleite::Vector2f.new 2.0, 2.0
    @sprite.rotation = 33.0

    @input = nil
  end

  def enable
    input = InputHandler.new(self)
    @app.input_router.register(input)
    @input = input
  end

  def disable
    @app.input_router.unregister(@input)
    @input = nil
  end

  def update(delta)
  end

  def render(delta, renderer)
    renderer.draw @sprite
  end
end