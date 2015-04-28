require 'parslet'

module DMARC
  class InvalidRecord < Parslet::ParseFailed
  end
end
