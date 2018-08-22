class SocialUnit
  include CrystalClear

  @id : SocialUnitId
  @name : String
  @members = SocialUnitMemberManager.new

  getter id, name
  protected getter members

  def initialize(@id, @name)
  end

  requires entity.has_component? SocialUnitMemberComponent
  requires !entity.query SocialUnitMemberComponent, &.owner.nil?
  requires !@members.includes? entity
  def register(entity)
    @members.register entity, self
  end

  requires @members.includes? entity
  ensures !@members.includes? entity
  def unregister(entity)
    @members.unregister entity
  end

  def update(world)
    clean_destroyed_members
  end

  def clean_destroyed_members
    @members.reject! { |e| e.destroyed? }
  end
end