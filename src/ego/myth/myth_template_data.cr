class MythTemplateData
  @id : String
  @type : MythTemplate::Type
  @text = ""
  @follows = [] of String
  @effects = [] of MythEffect

  getter id, type, text, follows, effects
  protected setter text, follows, effects

  def initialize(@id, @type)
  end
end