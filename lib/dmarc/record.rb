require 'dmarc/parser'

module DMARC
  class Record < Struct.new(:adkim, :aspf, :fo, :p, :pct, :rf, :ri, :rua, :ruf, :sp, :v)

    def self.from_txt(rec)
      new(DMARC::Parser.new.parse(rec))
    end

    DEFAULTS = {
      adkim: 'r',
      aspf:  'r',
      fo:    '0',
      pct:   100,
      rf:    'afrf',
      ri:    86400,
    }

    def initialize(tags=[])
      tags.reduce(DEFAULTS, &:merge).each_pair do |k,v|
        case k
        when :pct, :ri
          self[k] = v.to_i
        else
          self[k] = v
        end
      end

      self.sp ||= p
    end

  end
end
