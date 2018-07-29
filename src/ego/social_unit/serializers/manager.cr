class SocialUnitManager
  struct Serializer
    def marshal(obj, node)
      node.marshal "next_id", obj.id_generator.peak_next
      node.marshal "instances", obj.instances
    end

    def unmarshal(node)
      world = node.data
      id_generator = IdGenerator.new node.unmarshal_int("next_id")
      manager = SocialUnitManager.new id_generator
      pre_load_instances node, manager
      load_instances node, manager, world
      manager
    end

    def pre_load_instances(node, manager)
      instances_pre = node.unmarshal "instances", Array(SocialUnitPreLoadData)
      instances_pre.each do |data|
        unit = SocialUnit.new data.id
        manager.add unit
      end
    end

    def load_instances(node, manager, world)
      instances = node.value.as(Hash(Boleite::Serializer::Type, Boleite::Serializer::Type))["instances"]
      manager.each_with_index do |unit, index|
        data = { unit, world, manager }
        child = Boleite::Serializer::Node.new data, instances, index
        child.unmarshal index, SocialUnit
      end
    end
  end

  extend Boleite::Serializable(Serializer)
end