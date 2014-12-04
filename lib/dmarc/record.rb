require 'dmarc/parser'
require 'dmarc/exceptions'

require 'resolv'

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

    #
    # Queries and parses the DMARC record for a domain.
    #
    # @param [String] domain
    #   The domain to query DMARC for.
    #
    # @param [Resolv::DNS] resolver
    #   The resolver to use.
    #
    # @return [Record]
    #   The parsed DMARC record.
    #
    # @since 0.3.0
    #
    # @api public
    #
    def self.query(domain,resolver=Resolv::DNS.new)
      subdomain = "_dmarc.#{domain}"
      dmarc     = resolver.getresource(
        subdomain, Resolv::DNS::Resource::IN::TXT
      ).strings.join

      return parse(dmarc)
    end

  end
end
