class SocialUnitMemberComponent < EntityComponent
  @owner : SocialUnit?

  property owner

  def owner! : SocialUnit
    if o = @owner
      o
    else
      raise "Accessed social unit members owner while owner was nil!"
    end
  end

  def on_destroyed(entity)
    if su = @owner
      su.unregister entity
    end
  end
end
