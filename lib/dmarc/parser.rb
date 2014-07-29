require 'parslet'

module DMARC
  class Parser < Parslet::Parser

    root('dmarc_record')
    rule('dmarc_record') do
      dmarc_version >>
      (dmarc_sep >> (
        dmarc_request |
        dmarc_srequest |
        dmarc_auri |
        dmarc_furi |
        dmarc_adkim |
        dmarc_aspf |
        dmarc_ainterval |
        dmarc_fo |
        dmarc_rfmt |
        dmarc_percent
      )).repeat >>
      dmarc_sep.maybe
    end

    rule('dmarc_version') do
      str('v') >> wsp.repeat >>
      str('=') >> wsp.repeat >>
      str('DMARC1').as(:v)
    end
    rule('dmarc_sep') { wsp.repeat >> str(';') >> wsp.repeat }

    rule('dmarc_request') do
      str('p') >> wsp.repeat >> str('=') >> wsp.repeat >> (
        str('none') |
        str('quarantine') |
        str('reject')
      ).as(:p)
    end

    rule('dmarc_srequest') do
      str('sp') >> wsp.repeat >> str('=') >> wsp.repeat >> (
        str('none') |
        str('quarantine') |
        str('reject')
      ).as(:sp)
    end

    rule('dmarc_auri') do
      str('rua') >> wsp.repeat >> str('=') >> wsp.repeat >>
      dmarc_uri.as(:rua) >> (
        wsp.repeat >> str(',') >> wsp.repeat >> dmarc_uri.as(:rua)
      ).repeat
    end

    rule('dmarc_ainterval') do
      str('ri') >> wsp.repeat >> str('=') >> wsp.repeat >> digit.repeat(1).as(:ri)
    end

    rule('dmarc_furi') do
      str('ruf') >> wsp.repeat >> str('=') >> wsp.repeat >>
      dmarc_uri.as(:ruf) >> (wsp.repeat >> str(',') >> wsp.repeat >> dmarc_uri.as(:ruf)).repeat
    end

    rule('dmarc_fo') do
      str('fo') >> wsp.repeat >> str('=') >> wsp.repeat >> (
        str('0') |
        str('1') |
        str('d') |
        str('s')
      ).as(:fo) >> (
        wsp.repeat >> str(':') >> wsp.repeat >> (
          str('0') |
          str('1') |
          str('d') |
          str('s')
        ).as(:fo)
      ).repeat
    end

    rule('dmarc_rfmt') do
      str('rf') >> wsp.repeat >> str('=') >> wsp.repeat >> (
        str('afrf') |
        str('iodef')
      ).as(:rf)
    end

    rule('dmarc_percent') do
      str('pct') >> wsp.repeat >> str('=') >> wsp.repeat >> digit.repeat(1, 3).as(:pct)
    end

    rule('dmarc_adkim') do
      str('adkim') >> wsp.repeat >> str('=') >> wsp.repeat >> (
        str('r') |
        str('s')
      ).as(:adkim)
    end

    rule('dmarc_aspf') do
      str('aspf') >> wsp.repeat >> str('=') >> wsp.repeat >> (
        str('r') |
        str('s')
      ).as(:aspf)
    end

    rule('dmarc_uri') do
      uri.as(:uri) >> (
        str('!') >> digit.repeat(1).as(:size) >> (
          str('k') |
          str('m') |
          str('g') |
          str('t')
        ).as(:unit).maybe
      ).maybe
    end

    rule('uri') do
      ( absoluteURI | relativeURI ).maybe >>
      ( str('#') >> fragment ).maybe
    end
    rule('absoluteURI') { scheme >> str(':') >> ( hier_part | opaque_part ) }
    rule('relativeURI') do
      ( net_path | abs_path | rel_path ) >> ( str('?') >> query ).maybe
    end

    rule('hier_part') do
      ( net_path | abs_path ) >> ( str('?') >> query )
    end
    rule('opaque_part') do
      uric_no_slash >> uric.repeat
    end

    rule('uric_no_slash') do
      unreserved | escaped | match('[?:@&=+$]')
    end

    rule('net_path') { str('//') >> authority >> abs_path.maybe }
    rule('abs_path') { str('/') >> path_segments }
    rule('rel_path') { rel_segment >> abs_path.maybe }

    rule('rel_segment') { ( unreserved | escaped | match('[@&=+$]') ).repeat(1) }

    rule('scheme') { alpha >> ( alpha | digit | match('[+-.]') ).repeat }

    rule('authority') { server | reg_name }

    rule('reg_name') { ( unreserved | escaped | match('[$:@&=+]') ).repeat(1) }

    rule('server') { ( ( userinfo >> str('@') ).maybe >> hostport ).maybe }
    rule('userinfo') { ( unreserved | escaped | match('[:&=+$]') ).repeat }

    rule('hostport') { host >> ( str(':') >> port ).maybe }
    rule('host') { hostname | ipv4address }
    rule('hostname') do
      ( domainlabel >> str('.') ).repeat >> toplabel >> str('.').maybe
    end
    rule('domainlabel') do
      alphanum | (
        alphanum >> ( alphanum | str('-') ).repeat >> alphanum
      )
    end
    rule('toplabel') do
      alpha | (
        alpha >> ( alphanum | str('-') ).repeat >> alphanum
      )
    end
    rule('ipv4address') do
      digit.repeat(1) >> str('.') >>
      digit.repeat(1) >> str('.') >>
      digit.repeat(1) >> str('.') >>
      digit.repeat(1)
    end
    rule('port') { digit.repeat }

    rule('path') { ( abs_path | opaque_part ).maybe }
    rule('path_segments') { segment >> ( str('/') >> segment ).repeat }
    rule('segment') { pchar.repeat >> ( str(';') >> param ).repeat }
    rule('param') { pchar }
    rule('pchar') { unreserved | escaped | match('[:@&=+$]') }

    rule('query') { uric.repeat }
    rule('fragment') { uric.repeat }

    rule('uric') { reserved | unreserved | escaped }
    rule('reserved') { match('[/?:@&=+$]') }
    rule('unreserved') { alphanum | mark }
    rule('mark') { match("[-_.~*'()]") }
    rule('escaped') { str('%') >> hex >> hex }
    rule('hex') { digit | match('[a-fA-F]') }
    rule('alphanum') { alpha | digit }
    rule('alpha') { match('[a-zA-Z]') }
    rule('digit') { match('[0-9]') }
    rule('wsp') { str(' ') | str("\t") }

  end
end
