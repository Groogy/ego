class MythTemplate
  enum Type
    CreationStart
    Creation
  end

  @data : MythTemplateData

  delegate id, type, text, follows, to: @data
  protected getter data

  def initialize(@data : MythTemplateData)
  end
end