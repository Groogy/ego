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
    @sprite.position = Boleite::Vector2f.new 300.0, 300.0
    @sprite.origo = texture.size.to_f / 2.0
    @sprite.scale = Boleite::Vector2f.new 2.0, 2.0
    @sprite.rotation = 33.0
    #@sprite.texture_rect = Boleite::IntRect.new(0, 0, 100, 50)

    size = 129u32
    @font = Boleite::Font.new(app.graphics, "/usr/share/fonts/TTF/arial.ttf")
    puts "RENDERING 'a'"
    @font.get_glyph('a', size)
    puts "RENDERING 'b'"
    @font.get_glyph('b', size)
    puts "RENDERING 'c'"
    @font.get_glyph('c', size)
    puts "RENDERING 'd'"
    @font.get_glyph('d', size)
    puts "RENDERING 'e'"
    @font.get_glyph('e', size)
    puts "RENDERING 'f'"
    @font.get_glyph('f', size)
    @font.get_glyph('g', size)
    puts "RENDERING 'h'"
    @font.get_glyph('h', size)
    puts "RENDERING 'g'"

    @sprite2 = Boleite::Sprite.new @font.@pages[size].texture

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
    renderer.draw @sprite2
  end
end