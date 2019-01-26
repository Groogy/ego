require "boleite"
require "./ego/*"
require "./ego/interface/*"
require "./ego/serializers/*"
require "./ego/map/*"
require "./ego/map/serializers/*"
require "./ego/myth/*"
require "./ego/myth/serializers/*"
require "./ego/entity/*"
require "./ego/entity/components/*"
require "./ego/entity/components/serializers/*"
require "./ego/entity/systems/*"
require "./ego/entity/descriptors/*"
require "./ego/entity/serializers/*"
require "./ego/social_unit/*"
require "./ego/social_unit/serializers/*"
require "./ego/names/*"
require "./ego/names/serializers/*"

app = EgoApplication.new
app.state_stack.push MenuState.new(app)
app.run
