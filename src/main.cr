require "boleite"
require "./ego/*"
require "./ego/serializers/*"
require "./ego/tilemap/*"

app = EgoApplication.new
app.state_stack.push GameState.new(app)
app.run
