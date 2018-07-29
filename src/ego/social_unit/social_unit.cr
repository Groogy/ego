class SocialUnit
  include CrystalClear

  @id : SocialUnitId
  @members = [] of Entity

  getter id
  protected getter members

  def initialize(@id)
  end

  requires entity.has_component? SocialUnitMemberComponent
  requires !entity.query SocialUnitMemberComponent, &.owner.nil?
  requires !@members.includes? entity
  def register(entity)
    entity.query SocialUnitMemberComponent, &.owner=self
    @members << entity
  end

  requires @members.includes? entity
  ensures !@members.includes? entity
  def unregister(entity)
    @members.delete entity
    entity.query SocialUnitMemberComponent, &.owner=nil
  end

  def update(world)
    clean_destroyed_members
  end

  def clean_destroyed_members
    @members.reject! { |e| e.destroyed? }
  end
end