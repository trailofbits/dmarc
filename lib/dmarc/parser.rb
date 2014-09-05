require 'parslet'

module DMARC
  class Parser < Parslet::Parser

    root(:dmarc_record)
    rule(:dmarc_record) do
      dmarc_version >> dmarc_sep >> dmarc_request.maybe >>
      (dmarc_sep >> dmarc_tag).repeat >>
      dmarc_sep.maybe
    end

    rule(:dmarc_version) do
      str('v') >> wsp? >>
      str('=') >> wsp? >>
      str('DMARC1').as(:v)
    end
    rule(:dmarc_sep) { wsp? >> str(';') >> wsp? }

    rule(:dmarc_request) do
      str('p') >> wsp? >> str('=') >> wsp? >> (
        str('none') |
        str('quarantine') |
        str('reject')
      ).as(:p)
    end

    rule(:dmarc_tag) do
      dmarc_srequest  |
      dmarc_auri      |
      dmarc_furi      |
      dmarc_adkim     |
      dmarc_aspf      |
      dmarc_ainterval |
      dmarc_fo        |
      dmarc_rfmt      |
      dmarc_percent   |
      unknown_tag
    end

    def self.tag_rule(name,tag,&block)
      rule(:"dmarc_#{name}") do
        str(tag) >> wsp? >> str('=') >> wsp? >>
        instance_eval(&block).as(tag.to_sym)
      end
    end

    tag_rule(:srequest,'sp') do
      str('none') | str('quarantine') | str('reject')
    end

    tag_rule(:auri, 'rua') do
      dmarc_uri >> (wsp? >> str(',') >> wsp? >> dmarc_uri).repeat
    end

    tag_rule(:ainterval,'ri') { digit.repeat(1) }

    tag_rule(:furi,'ruf') do
      dmarc_uri >> (wsp? >> str(',') >> wsp? >> dmarc_uri).repeat
    end

    tag_rule(:fo,'fo') do
      fo >> (wsp? >> str(':') >> wsp? >> fo).repeat
    end

    rule(:fo) { match['01ds'].as(:opt) }

    tag_rule(:rfmt,'rf') { str('afrf') | str('iodef') }

    tag_rule(:percent,'pct') { digit.repeat(1,3) }

    rule(:dmarc_adkim) do
      str('adkim') >> wsp? >> str('=') >> wsp? >> (
        str('r') |
        str('s')
      ).as(:adkim)
    end

    rule(:dmarc_aspf) do
      str('aspf') >> wsp? >> str('=') >> wsp? >> (
        match['rs']
      ).as(:aspf)
    end

    rule(:unknown_tag) { match["^; \t"].repeat(1) }
    rule(:unknown_value) { match["^=; \t"].repeat(1) }

    rule(:dmarc_uri) do
      uri.as(:uri) >> (
        str('!') >> digit.repeat(1).as(:size) >> (
          match['kmgt']
        ).as(:unit).maybe
      ).maybe
    end

    rule(:uri) do
      ( absoluteURI | relativeURI ).maybe >>
      ( str('#') >> fragment ).maybe
    end
    rule(:absoluteURI) { scheme >> str(':') >> ( hier_part | opaque_part ) }
    rule(:relativeURI) do
      ( net_path | abs_path | rel_path ) >> ( str('?') >> query ).maybe
    end

    rule(:hier_part) do
      ( net_path | abs_path ) >> ( str('?') >> query )
    end
    rule(:opaque_part) do
      uric_no_slash >> uric.repeat
    end

    rule(:uric_no_slash) do
      unreserved | escaped | match('[?:@&=+$]')
    end

    rule(:net_path) { str('//') >> authority >> abs_path.maybe }
    rule(:abs_path) { str('/') >> path_segments }
    rule(:rel_path) { rel_segment >> abs_path.maybe }

    rule(:rel_segment) { ( unreserved | escaped | match('[@&=+$]') ).repeat(1) }

    rule(:scheme) { alpha >> ( alpha | digit | match('[+-.]') ).repeat }

    rule(:authority) { server | reg_name }

    rule(:reg_name) { ( unreserved | escaped | match('[$:@&=+]') ).repeat(1) }

    rule(:server) { ( ( userinfo >> str('@') ).maybe >> hostport ).maybe }
    rule(:userinfo) { ( unreserved | escaped | match('[:&=+$]') ).repeat }

    rule(:hostport) { host >> ( str(':') >> port ).maybe }
    rule(:host) { hostname | ipv4address }
    rule(:hostname) do
      ( domainlabel >> str('.') ).repeat >> toplabel >> str('.').maybe
    end
    rule(:domainlabel) do
      alphanum | (
        alphanum >> ( alphanum | str('-') ).repeat >> alphanum
      )
    end
    rule(:toplabel) do
      alpha | (
        alpha >> ( alphanum | str('-') ).repeat >> alphanum
      )
    end
    rule(:ipv4address) do
      digit.repeat(1) >> str('.') >>
      digit.repeat(1) >> str('.') >>
      digit.repeat(1) >> str('.') >>
      digit.repeat(1)
    end
    rule(:port) { digit.repeat }

    rule(:path) { ( abs_path | opaque_part ).maybe }
    rule(:path_segments) { segment >> ( str('/') >> segment ).repeat }
    rule(:segment) { pchar.repeat >> ( str(';') >> param ).repeat }
    rule(:param) { pchar }
    rule(:pchar) { unreserved | escaped | match('[:@&=+$]') }

    rule(:query) { uric.repeat }
    rule(:fragment) { uric.repeat }

    rule(:uric) { reserved | unreserved | escaped }
    rule(:reserved) { match('[/?:@&=+$]') }
    rule(:unreserved) { alphanum | mark }
    rule(:mark) { match("[-_.~*'()]") }
    rule(:escaped) { str('%') >> hex >> hex }
    rule(:hex) { digit | match('[a-fA-F]') }
    rule(:alphanum) { alpha | digit }
    rule(:alpha) { match('[a-zA-Z]') }
    rule(:digit) { match('[0-9]') }
    rule(:wsp) { str(' ') | str("\t") }
    rule(:wsp?) { wsp.repeat }

  end

  class Transform < Parslet::Transform

    rule(tags: sequence(:tags)) do
      hash = {}

      tags.each_with_object(hash,&:merge!)

      hash
    end
  end
end
