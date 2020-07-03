require 'dmarc/dmarc'
require 'dmarc/parser'
require 'dmarc/exceptions'

require 'resolv'

module DMARC
  class Record

    # `p` field.
    # 
    # @return [:none, :quarantine, :reject]
    attr_accessor :p

    # `rua` field.
    #
    # @return [Array<Uri>]
    attr_accessor :rua

    # `rua` field.
    #
    # @return [Array<Uri>]
    attr_accessor :ruf

    # `sp` field.
    # 
    # @return [:none, :quarantine, :reject]
    attr_accessor :sp

    # `v` field.
    #
    # @return [:DMARC1]
    attr_accessor :v

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
    # @option attributes [Array<Uri>] :rua
    #
    # @option attributes [Array<Uri>] :ruf
    #
    # @option attributes [:none, :quarantine, :reject] :sp
    #
    # @option attributes [:DMARC1] :v
    #
    def initialize(attributes={})
      @v     = attributes.fetch(:v)
      @adkim = attributes[:adkim]
      @aspf  = attributes[:aspf]
      @fo    = attributes[:fo]
      @p     = attributes[:p]
      @pct   = attributes[:pct]
      @rf    = attributes[:rf]
      @ri    = attributes[:ri]
      @rua   = attributes[:rua]
      @ruf   = attributes[:ruf]
      @sp    = attributes[:sp]
    end

    #
    # Determines if the `sp=` field was specified?
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def sp?
      !@sp.nil?
    end

    #
    # The `sp=` field.
    #
    # @return [:none, :quarantine, :reject]
    #   The value of the `sp=` field, or that of {#p} if the field was omitted.
    #
    def sp
      @sp || @p
    end

    #
    # Determines whether the `adkim=` field was specified.
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def adkim?
      !@adkim.nil?
    end

    #
    # `adkim=` field.
    #
    # @return [:r, :s]
    #   The value of the `adkim=` field, or `:r` if the field was omitted.
    #
    def adkim
      @adkim || :r
    end

    #
    # Determines whether the `aspf=` field was specified.
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def aspf?
      !@aspf.nil?
    end

    #
    # `aspf` field.
    #
    # @return [:r, :s]
    #   The value of the `aspf=` field, or `:r` if the field was omitted.
    #
    def aspf
      @aspf || :r
    end

    #
    # Determines whether the `fo=` field was specified.
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def fo?
      !@fo.nil?
    end

    #
    # `fo` field.
    #
    # @return [Array<'0', '1', 'd', 's'>]
    #   The value of the `fo=` field, or `["0"]` if the field was omitted.
    #
    def fo
      @fo || %w[0]
    end

    #
    # Determines if the `p=` field was specified?
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def p?
      !@p.nil?
    end

    #
    # Determines whether the `pct=` field was specified.
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def pct?
      !@pct.nil?
    end

    #
    # `pct` field.
    #
    # @return [Integer]
    #   The value of the `pct=` field, or `100` if the field was omitted.
    #
    def pct
      @pct || 100
    end

    #
    # Determines whether the `rf=` field was specified.
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def rf?
      !@rf.nil?
    end

    #
    # `rf` field.
    # 
    # @return [:afrf, :iodef]
    #   The value of the `rf=` field, or `:afrf` if the field was omitted.
    #
    def rf
      @rf || :afrf
    end

    #
    # Determines whether the `ri=` field was specified.
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def ri?
      !@ri.nil?
    end

    #
    # `ri` field.
    #
    # @return [Integer]
    #   The value of the `ri=` field, or `86400` if the field was omitted.
    #
    def ri
      @ri || 86400
    end

    #
    # Determines if the `rua=` field was specified?
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def rua?
      !@rua.nil?
    end

    #
    # Determines if the `ruf=` field was specified?
    #
    # @return [Boolean]
    #
    # @since 0.4.0
    #
    def ruf?
      !@ruf.nil?
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
    # Converts the record to a Hash.
    #
    # @return [Hash{Symbol => Object}]
    #
    # @since 0.4.0
    #
    def to_h
      hash = {}

      hash[:v]     = @v     if @v
      hash[:p]     = @p     if @p
      hash[:sp]    = @sp    if @sp
      hash[:rua]   = @rua   if @rua
      hash[:ruf]   = @ruf   if @ruf
      hash[:adkim] = @adkim if @adkim
      hash[:aspf]  = @aspf  if @aspf
      hash[:ri]    = @ri    if @ri
      hash[:fo]    = @fo    if @fo
      hash[:rf]    = @rf    if @rf
      hash[:pct]   = @pct   if @pct

      return hash
    end

    #
    # Converts the record back to a DMARC String.
    #
    # @return [String]
    #
    def to_s
      tags = []

      tags << "v=#{@v}"               if @v
      tags << "p=#{@p}"               if @p
      tags << "sp=#{@sp}"             if @sp
      tags << "rua=#{@rua.join(',')}" if @rua
      tags << "ruf=#{@ruf.join(',')}" if @ruf
      tags << "adkim=#{@adkim}"       if @adkim
      tags << "aspf=#{@aspf}"         if @aspf
      tags << "ri=#{@ri}"             if @ri
      tags << "rf=#{@rf.join(',')}"   if @rf
      tags << "fo=#{@fo.join(':')}"   if @fo
      tags << "pct=#{@pct}"           if @pct

      return tags.join('; ')
    end

  end
end
