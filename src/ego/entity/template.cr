class EntityTemplate
  include CrystalClear

  @data : EntityTemplateData
  @categories = [] of EntityCategory

  delegate id, name, description, size, graphics, to: @data
  protected getter data
  protected property categories

  def initialize(@data : EntityTemplateData)
  end

  def primary_category
    @categories.first
  end

  def has_category?(cat : EntityCategory)
    @categories.includes? cat
  end

  def has_category?(str : String)
    @categories.any? { |cat| cat.id == str }
  end

  def allocate_components
    arr = [] of EntityComponent
    @data.components.each do |data|
      klass = EntityComponent.find_class data.id
      assert klass != nil
      arr << klass.allocate if klass
    end
    arr
  end

  def has_component?(id : String)
    @data.components.find { |obj| obj.id == id } != nil
  end

  def has_component?(klass)
    has_component? klass.id
  end

  requires has_component? id
  def get_component_data(id : String)
    @data.components.find { |obj| obj.id == id }
  end

  def get_component_data(index : Int)
    @data.components[index]
  end
end