class Deity
  enum Gender
    Neutral
    Male
    Female

    def to_pronoun
      case self
      when Neutral then "it"
      when Male then "he"
      when Female then "she"
      end
    end
  end

  @gender = Gender::Neutral

  property gender

  def initialize
  end
end