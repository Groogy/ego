class HarvesterComponent
  struct Serializer
    def marshal(obj, node)
      obj = obj.as(HarvesterComponent)
      if area = obj.area
        node.marshal "area", area
      end
      if tmpl = obj.target_tmpl
        node.marshal "target", tmpl.id
      end
    end

    def unmarshal(obj, node)
      world = node.data[1]
      obj = obj.as(HarvesterComponent)
      if node.has? "area"
        obj.area = node.unmarshal "area", Array(Map::Pos)
      end
      if node.has? "target"
        target_key = node.unmarshal_string "target"
        obj.target_tmpl = world.entity_templates.get target_key
      end
    end
  end

  def self.component_serializer
    Serializer.new
  end
end


class HarvestTask < AgentTask
  struct Serializer < BaseSerializer
    def marshal(obj, node)
      super obj, node
      obj = obj.as(HarvestTask)
      node.marshal "progress", obj.progress
      if container = obj.container
        node.marshal "container", container.id
      end
    end

    def unmarshal(node)
      world = node.data[1]
      entities = node.data[2]
      task = unmarshal node, HarvestTask
      task.progress = node.unmarshal_int("progress").to_i32
      if node.has? "container"
        id = node.unmarshal_int "container"
        task.container = entities.find_by_id id
      end
      task
    end
  end

  extend Boleite::Serializable(Serializer)
end