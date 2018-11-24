class SocialUnit
  struct Serializer
    def marshal(obj, node)
      node.marshal "id", obj.id
      node.marshal "name", obj.name
      members = obj.members.map &.id
      node.marshal "members", members
      node.marshal "resources", obj.resources
    end

    def unmarshal(node)
      instance = node.data[0] # We've preloaded some data
      world = node.data[1]
      assert instance.id == node.unmarshal_int "id"
      load_members node, instance, world
      instance.resources = node.unmarshal "resources", SocialUnitResourceTracker
      instance
    end

    def load_members(node, obj, world)
      entities = world.entities
      ids = node.unmarshal "members", Array(EntityId)
      ids.each do |i|
        e = entities.find_by_id i
        assert !e.nil?
        obj.register e if e
      end
    end
  end

  extend Boleite::Serializable(Serializer)
end