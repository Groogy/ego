require "boleite"
require "./ego/*"
require "./ego/interface/*"
require "./ego/serializers/*"
require "./ego/map/*"
require "./ego/map/serializers/*"
require "./ego/entity/*"
require "./ego/entity/components/*"
require "./ego/entity/components/serializers/*"
require "./ego/entity/systems/*"
require "./ego/entity/serializers/*"

app = EgoApplication.new
app.state_stack.push MenuState.new(app)
app.run
