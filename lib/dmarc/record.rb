require 'dmarc/parser'
require 'dmarc/exceptions'

module DMARC
  class Record < Struct.new(:adkim, :aspf, :fo, :p, :pct, :rf, :ri, :rua, :ruf, :sp, :v)

    DEFAULTS = {
      adkim: 'r',
      aspf:  'r',
      fo:    '0',
      pct:   100,
      rf:    'afrf',
      ri:    86400,
    }

    def initialize(attributes={})
      attributes.merge(DEFAULTS).each_pair do |k,v|
        self[k] = v
      end

      self.sp ||= p
    end

    #
    # @since 0.3.0
    #
    # @api public
    #
    def self.parse(rec)
      new(Parser.new.parse(rec))
    rescue Parslet::ParseFailed
      raise InvalidRecord
    end

    #
    # @deprecated use {parse} instead.
    #
    def self.from_txt(rec)
      parse(rec)
    end

  end
end
