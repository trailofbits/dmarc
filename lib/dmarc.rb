require 'dmarc/exceptions'
require 'dmarc/record'
require 'dmarc/parser'
require 'dmarc/version'

require 'resolv'

module DMARC
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
  def self.query(domain,resolver=Resolv::DNS.new)
    subdomain = "_dmarc.#{domain}"
    dmarc     = resolver.getresource(
      subdomain, Resolv::DNS::Resource::IN::TXT
    ).strings.join

    Record.parse(dmarc)
  end
end
