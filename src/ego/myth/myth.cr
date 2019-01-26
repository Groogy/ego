class Myth
  getter template
  
  def initialize(@template : MythTemplate)
  end

  def apply(world, deity)
    @template.effects.each do |e|
      e.apply world, deity
    end
  end
end