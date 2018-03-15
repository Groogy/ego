require "boleite"
require "./ego/*"
require "./ego/interface/*"
require "./ego/serializers/*"
require "./ego/map/*"
require "./ego/map/serializers/*"

app = EgoApplication.new
app.state_stack.push GameState.new(app)
app.run
