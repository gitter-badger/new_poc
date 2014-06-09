
# Blog class encapsulates the blog as a whole.
class Blog
  attr_reader :title, :subtitle, :entries

  def initialize
    @title = 'Watching Paint Dry'
    @subtitle = 'The trusted source for drying paint news and opinion'
    @entries = []
  end
end # class Blog
