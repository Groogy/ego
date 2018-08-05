struct SocialUnitPreLoadData
  @id : SocialUnitId
  @name : String

  getter id, name

  def initialize(@id, @name)
  end

  struct Serializer
    def unmarshal(node)
      id = node.unmarshal_int "id"
      name = node.unmarshal_string "name"
      SocialUnitPreLoadData.new id, name
    end
  end

  extend Boleite::Serializable(Serializer)
end