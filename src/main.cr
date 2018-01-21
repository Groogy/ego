require "boleite"
require "./ego/*"
require "./ego/serializers/*"
require "./ego/tilemap/*"
require "./ego/map/*"

app = EgoApplication.new
app.state_stack.push GameState.new(app)
app.run
