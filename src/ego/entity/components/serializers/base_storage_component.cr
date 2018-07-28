abstract class BaseStorageComponent
  struct Serializer
    def marshal(obj, node)
      obj = obj.as(BaseStorageComponent)
      ids = obj.entities.map { |item| item.id }
      node.marshal "entities", ids
    end

    def unmarshal(obj, node)
      world = node.data[1]
      entities = node.data[2]
      obj = obj.as(BaseStorageComponent)
      ids = node.unmarshal "entities", Array(Int64)
      obj.entities = ids.compact_map { |id| entities.find_by_id id }
      obj
    end
  end

  def self.component_serializer
    Serializer.new
  end
end