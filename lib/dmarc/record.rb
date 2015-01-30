require 'dmarc/dmarc'
require 'dmarc/parser'
require 'dmarc/exceptions'

require 'resolv'

module DMARC
  class Record

    DEFAULTS = {
      adkim: :r,
      aspf:  :r,
      fo:    ['0'],
      pct:   100,
      rf:    :afrf,
      ri:    86400,
    }.freeze

    # `adkim` field.
    #
    # @return [:r, :s]
    attr_reader :adkim

    # `aspf` field.
    #
    # @return [:r, :s]
    attr_reader :aspf

    # `fo` field.
    #
    # @return [Array<'0', '1', 'd', 's'>]
    attr_reader :fo

    # `p` field.
    # 
    # @return [:none, :quarantine, :reject]
    attr_reader :p

    # `pct` field.
    #
    # @return [Integer]
    attr_reader :pct

    # `rf` field.
    # 
    # @return [:afrf, :iodef]
    attr_reader :rf

    # `ri` field.
    #
    # @return [Integer]
    attr_reader :ri

    # `rua` field.
    #
    # @return [Array<URI::MailTo>]
    attr_reader :rua

    # `rua` field.
    #
    # @return [Array<URI::MailTo>]
    attr_reader :ruf

    # `sp` field.
    # 
    # @return [:none, :quarantine, :reject]
    attr_reader :sp

    # `v` field.
    #
    # @return [:DMARC1]
    attr_reader :v

    #
    # Initializes the record.
    #
    # @param [Hash{Symbol => Object}] attributes
    #   Attributes for the record.
    #
    # @option attributes [:r, :s] :adkim (:r)
    #
    # @option attributes [:r, :s] :aspf (:r)
    #
    # @option attributes [Array<'0', '1', 'd', 's'>] :fo ('0')
    #
    # @option attributes [:none, :quarantine, :reject] :p
    #
    # @option attributes [Integer] :pct (100)
    #
    # @option attributes [:afrf, :iodef] :rf (:afrf)
    #
    # @option attributes [Integer] :ri (86400)
    #
    # @option attributes [Array<URI::MailTo>] :rua
    #
    # @option attributes [Array<URI::MailTo>] :ruf
    #
    # @option attributes [:none, :quarantine, :reject] :sp
    #
    # @option attributes [:DMARC1] :v
    #
    def initialize(attributes={})
      attributes = DEFAULTS.merge(attributes)

      @adkim, @aspf, @fo, @p, @pct, @rf, @ri, @rua, @ruf, @sp, @v = attributes.values_at(:adkim, :aspf, :fo, :p, :pct, :rf, :ri, :rua, :ruf, :sp, :v)

      @sp ||= @p
    end

    #
    # @since 0.3.0
    #
    # @api public
    #
    def self.parse(rec)
      new(Parser.parse(rec))
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
    # @return [Record, nil]
    #   The parsed DMARC record. If no DMARC record was found, `nil` will be
    #   returned.
    #
    # @since 0.3.0
    #
    # @api public
    #
    def self.query(domain,resolver=Resolv::DNS.new)
      if (dmarc = DMARC.query(domain,resolver))
        parse(dmarc)
      end
    end

  end
end
