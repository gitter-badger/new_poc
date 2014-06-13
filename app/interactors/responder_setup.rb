
module DSO
  # Module with mixin method to set up Wisper responders for Publisher DSOs.
  module ResponderSetup
    # This is where we'd wire up Wisper subscriber class instances to any
    # events published as a result of calling #execute. Note that this uses the
    # "Scoping to publisher class" protocol described in the Wisper README at
    # https://github.com/krisleech/wisper#scoping-to-publisher-class
    # Note also that this method *must* return `self`, as it's a class method
    # normally called inline with the .run or .run! methods; see an example at
    # https://github.com/jdickey/new_poc/issues/3#issuecomment-45978960
    def setup_responders(classes = [])
      classes.each do |klass|
        Wisper.add_listener klass.new, scope: name.to_sym
      end
      self
    end
  end # module DSO::ResponderSetup
end # module DSO
