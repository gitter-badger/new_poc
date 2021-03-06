
# Simple and to the point.
module DecoratorShared
  # Provides uniform formatting for timestamps.
  def timestamp_for(the_time = Time.now)
    the_time.to_time.localtime.strftime timestamp_format
  end

  def timestamp_format
    '%a %b %e %Y at %R %Z (%z)'
  end
end # module DecoratorShared
