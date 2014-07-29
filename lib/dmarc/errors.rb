module DMARC
  class Error < StandardError; end
  class InvalidRecord < Error
    def ascii_tree
      # First `cause` is ruby 2.1 exception cause
      # Second `cause` is a method defined by parslet on the ParseFailed error
      self.cause.cause.ascii_tree
    end
  end
end
