struct EntityPreLoadData
  @id : EntityId
  @template : EntityTemplate
  @pos : EntityPos

  getter id, template, pos

  def initialize(@id, @template, @pos)
  end

  struct Serializer
    def unmarshal(node)
      templates = node.data.entity_templates
      id = node.unmarshal_int "id"
      tmpl_key = node.unmarshal_string "tmpl"
      tmpl = templates.get tmpl_key
      pos = node.unmarshal "pos", EntityPos
      EntityPreLoadData.new id, tmpl, pos
    end
  end

  extend Boleite::Serializable(Serializer)
end