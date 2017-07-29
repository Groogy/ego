class GameState < Boleite::State
  class InputHandler < Boleite::InputReceiver
    def initialize(state)
      register Boleite::PassThroughAction, ->on_input(Boleite::InputEvent)
    end

    def on_input(event)
      p event
    end
  end

  @input : InputHandler | Nil
  
  def initialize(@app : EgoApplication)
    super()

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

  def update
  end

  def render
  end
end