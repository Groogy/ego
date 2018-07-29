struct SocialUnitPreLoadData
  @id : SocialUnitId

  getter id

  def initialize(@id)
  end

  struct Serializer
    def unmarshal(node)
      id = node.unmarshal_int "id"
      SocialUnitPreLoadData.new id
    end
  end

  extend Boleite::Serializable(Serializer)
end