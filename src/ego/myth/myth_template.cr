class MythTemplate
  enum Type
    CreationStart
    Creation
  end

  @data : MythTemplateData

  delegate id, type, text, follows, effects, to: @data
  protected getter data

  def initialize(@data : MythTemplateData)
  end

  def generate_text(world, deity)
    text = @data.text.gsub /(\[.*?\])/ do |r|
      replace_keys r, world, deity
    end
    text
  end

  private def replace_keys(key, world, deity)
    case key.downcase
    when "[godpronoun]" then deity.gender.to_pronoun
    else "[#{key}]"
    end
  end
end