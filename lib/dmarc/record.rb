require 'dmarc/dmarc'
require 'dmarc/parser'
require 'dmarc/exceptions'

require 'resolv'

module DMARC
  class Record

    # `p` field.
    # 
    # @return [:none, :quarantine, :reject]
    attr_reader :p

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
      @adkim, @aspf, @fo, @p, @pct, @rf, @ri, @rua, @ruf, @sp, @v = attributes.values_at(:adkim, :aspf, :fo, :p, :pct, :rf, :ri, :rua, :ruf, :sp, :v)
    end

    def sp
      @sp || @p
    end

    #
    # `adkim=` field.
    #
    # @return [:r, :s]
    #
    def adkim
      @adkim || :r
    end

    #
    # `aspf` field.
    #
    # @return [:r, :s]
    #
    def aspf
      @aspf || :r
    end

    #
    # `fo` field.
    #
    # @return [Array<'0', '1', 'd', 's'>]
    #
    def fo
      @fo || %w[0]
    end

    #
    # `pct` field.
    #
    # @return [Integer]
    #
    def pct
      @pct || 100
    end

    #
    # `rf` field.
    # 
    # @return [:afrf, :iodef]
    #
    def rf
      @rf || :afrf
    end

    #
    # `ri` field.
    #
    # @return [Integer]
    #
    def ri
      @ri || 86400
    end

    #
    # Parses a DMARC record.
    #
    # @param [String] record
    #   The raw DMARC record.
    #
    # @return [Record]
    #   The parsed DMARC record.
    #
    # @raise [InvalidRecord]
    #   The DMARC record could not be parsed.
    #
    # @since 0.3.0
    #
    # @api public
    #
    def self.parse(record)
      new(Parser.parse(record))
    rescue Parslet::ParseFailed => error
      raise(InvalidRecord.new(error.message,error.cause))
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
    # @raise [InvalidRecord]
    #   The DMARC record could not be parsed.
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

    #
    # Converts the record back to a DMARC String.
    #
    # @return [String]
    #
    def to_s
      tags = []

      tags << "v=#{@v}" if @v
      tags << "p=#{@p}" if @p
      tags << "sp=#{@sp}" if @sp
      tags << "rua=#{@rua.join(',')}" if @rua
      tags << "ruf=#{@ruf.join(',')}" if @ruf
      tags << "adkim=#{@adkim}" if @adkim
      tags << "aspf=#{@aspf}" if @aspf
      tags << "ri=#{@ri}" if @ri
      tags << "fo=#{@fo.join(':')}" if @fo
      tags << "rf=#{@rf}" if @rf
      tags << "pct=#{@pct}" if @pct

      return tags.join('; ')
    end

  end
end
