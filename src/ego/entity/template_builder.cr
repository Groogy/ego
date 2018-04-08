class EntityTemplate
  struct Builder
    @tmpl : EntityTemplate

    def initialize(@tmpl)
    end

    def post_load(manager)
    end
  end
end