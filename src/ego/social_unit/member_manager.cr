class SocialUnitMemberManager
  @members = [] of Entity

  delegate includes?, any?, all?, to: @members

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

  def each_non_agent
    @members.each { |e| yield e unless e.is_component_a? AgentBaseComponent }
  end

  def each_storage
    each_non_agent { |e| yield e if e.is_component_a? BaseStorageComponent }
  end

  def map
    @members.map { |e| yield e }
  end

  def select
    @members.select { |e| yield e }
  end

  def reject!(&block)
    found = @members.select { |e| yield e }
    found.each { |e| unregister e }
    found
  end

  def find_agent_provider(klass)
    each do |e|
      return e if e.query AgentProviderComponent, &.available_agent?(klass)
    end
    return nil
  end
end
