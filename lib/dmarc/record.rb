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

    def self.from_txt(rec)
      new(Parser.new.parse(rec))
    rescue Parslet::ParseFailed
      raise InvalidRecord
    end

  end
end
