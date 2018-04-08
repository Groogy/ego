class EntityTemplate
  struct Builder
    @tmpl : EntityTemplate

    def initialize(@tmpl)
    end

    def post_load(world)
      categories_manager = world.entity_categories
      load_categories categories_manager
    end

    def load_categories(manager)
      keys = @tmpl.data.categories
      @tmpl.categories = keys.map do |key|
        manager.get_category key
      end
    end
  end
end