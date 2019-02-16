require "boleite"
require "./ego/*"
require "./ego/interface/*"
require "./ego/serializers/*"
require "./ego/map/*"
require "./ego/map/serializers/*"
require "./ego/myth/*"
require "./ego/myth/serializers/*"
require "./ego/names/*"
require "./ego/names/serializers/*"

app = EgoApplication.new
app.state_stack.push MenuState.new(app)
app.run
