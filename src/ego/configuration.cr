class AppConfiguration < Boleite::Configuration
  def foobar
    @foobar
  end

  protected def foobar=(@foobar)
  end

  @foobar = "Hello World!"
end