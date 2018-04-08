class EntityTemplateManager
end

class EntityManager
  include CrystalClear

  @templates = EntityTemplateManager.new

  getter templates
end