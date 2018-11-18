class AgentProviderComponent
  struct Serializer
    def marshal(obj, node)
      obj = obj.as(AgentProviderComponent)
      tmpls = obj.agent_templates
      tmpls.each do |tmpl|
        agents = obj.active_agents_for tmpl
        ids = agents.map { |a| a.id }
        node.marshal tmpl.id, ids
      end
    end

    def unmarshal(obj, node)
      templates = node.data[1].entity_templates
      entities = node.data[2]
      obj = obj.as(AgentProviderComponent)
      node.each_child do |child|
        unmarshal_child obj, node, child.key.as(String), templates, entities
      end
    end

    def unmarshal_child(obj, node, key, templates, entities)
      if templates.has? key
        tmpl = templates.get key
        ids = node.unmarshal key, Array(Int64)
        ids.each do |id|
          entity = entities.find_by_id id
          assert !entity.nil?
          obj.add_agent_for tmpl, entity if entity
        end
      end
    end
  end

  def self.component_serializer
    Serializer.new
  end
end