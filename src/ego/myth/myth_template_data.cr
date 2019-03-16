class MythTemplateData
  @id : String
  @type : MythTemplate::Type
  @text = ""
  @follows = [] of String
  @exclusive = [] of String
  @effects = [] of MythEffect

  getter id, type, text, follows, exclusive, effects
  protected setter text, follows, exclusive, effects

  def initialize(@id, @type)
  end
end