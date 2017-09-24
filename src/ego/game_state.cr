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
    texture2 = @app.graphics.create_texture
    texture2.create(texture.size.x, texture.size.y, texture.format, texture.type)
    texture2.update(texture)
    @sprite = Boleite::Sprite.new texture
    @sprite.position = Boleite::Vector2f.new 500.0, 600.0
    @sprite.origo = texture.size.to_f / 2.0
    @sprite.scale = Boleite::Vector2f.new 2.0, 2.0
    @sprite.rotation = 33.0

    @font = Boleite::Font.new app.graphics, "/usr/share/fonts/TTF/arial.ttf"
    @text = Boleite::Text.new @font, "Hello world!\nNew line?"
    @text.size = 150u32
    @text.position = Boleite::Vector2f.new 10.0, 10.0

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
    @sprite.rotate delta.to_f * 10
    renderer.draw @sprite
    renderer.draw @text
  end
end