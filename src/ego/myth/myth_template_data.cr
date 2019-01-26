class MythTemplateData
  @id : String
  @type : MythTemplate::Type
  @text = ""

  getter id, type, text
  protected setter text

  def initialize(@id, @type)
  end
end