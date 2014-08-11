require 'parslet'

module DMARC
  class Parser < Parslet::Parser

    root(:dmarc_record)
    rule(:dmarc_record) do
      dmarc_version >> dmarc_sep >>
      dmarc_request.maybe >>
      (dmarc_sep >> dmarc_srequest).maybe >>
      (dmarc_sep >> dmarc_auri).maybe >>
      (dmarc_sep >> dmarc_furi).maybe >>
      (dmarc_sep >> dmarc_adkim).maybe >>
      (dmarc_sep >> dmarc_aspf).maybe >>
      (dmarc_sep >> dmarc_ainterval).maybe >>
      (dmarc_sep >> dmarc_fo).maybe >>
      (dmarc_sep >> dmarc_rfmt).maybe >>
      (dmarc_sep >> dmarc_percent).maybe >>
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

    rule(:dmarc_srequest) do
      str('sp') >> wsp? >> str('=') >> wsp? >> (
        str('none') |
        str('quarantine') |
        str('reject')
      ).as(:sp)
    end

    rule(:dmarc_auri) do
      str('rua') >> wsp? >> str('=') >> wsp? >>
      (dmarc_uri >> (wsp? >> str(',') >> wsp? >> dmarc_uri).repeat).as(:rua)
    end

    rule(:dmarc_ainterval) do
      str('ri') >> wsp? >> str('=') >> wsp? >> digit.repeat(1).as(:ri)
    end

    rule(:dmarc_furi) do
      str('ruf') >> wsp? >> str('=') >> wsp? >>
      (dmarc_uri >> (wsp? >> str(',') >> wsp? >> dmarc_uri).repeat).as(:ruf)
    end

    rule(:dmarc_fo) do
      str('fo') >> wsp? >> str('=') >> wsp? >>
      match['01ds'].as(:fo) >> (
        wsp? >> str(':') >> wsp? >> match['01ds'].as(:fo)
      ).repeat
    end

    rule(:dmarc_rfmt) do
      str('rf') >> wsp? >> str('=') >> wsp? >> (
        str('afrf') |
        str('iodef')
      ).as(:rf)
    end

    rule(:dmarc_percent) do
      str('pct') >> wsp? >> str('=') >> wsp? >> digit.repeat(1, 3).as(:pct)
    end

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
end
