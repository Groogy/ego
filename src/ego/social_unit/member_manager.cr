class SocialUnitMemberManager
  @members = [] of Entity

  delegate includes?, to: @members

  def register(entity, unit)
    entity.query SocialUnitMemberComponent, &.owner=unit
    @members << entity
  end

  def unregister(entity)
    @members.delete entity
    entity.query SocialUnitMemberComponent, &.owner=nil
  end

  def each
    @members.each { |e| yield e }
  end

  def map
    @members.map { |e| yield e }
  end

  def reject!(&block)
    found = @members.select { |e| yield e }
    found.each { |e| unregister e }
    found
  end
end