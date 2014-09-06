module DMARC
  class Error < StandardError; end
  class InvalidRecord < Error
    attr_reader :original

    def initialize(msg = nil, original = $!)
      super msg
      @original = original
    end

    def ascii_tree
      # `cause` is a method defined by parslet on the ParseFailed error
      # Not to be confused with ruby 2.1's Exception#cause method
      if self.original != nil
        self.original.cause.ascii_tree
      end
    end
  end
end
