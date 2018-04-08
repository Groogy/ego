class EntityTemplate
  struct Builder
    @tmpl : EntityTemplate

    def initialize(@tmpl)
    end

    def post_load(world)
    end
  end
end