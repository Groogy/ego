require "boleite"
require "./ego/*"
require "./ego/serializers/*"

app = EgoApplication.new
app.state_stack.push GameState.new(app)
app.run
