class MythTemplateData
  @id : String
  @type : MythTemplate::Type
  @text = ""
  @follows = [] of String

  getter id, type, text, follows
  protected setter text, follows

  def initialize(@id, @type)
  end
end