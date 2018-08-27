class SocialUnitMemberComponent < EntityComponent
  @owner : SocialUnit?

  property owner

  def on_destroyed(entity)
    if su = @owner
      su.unregister entity
    end
  end
end
