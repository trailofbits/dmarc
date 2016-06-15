# DMARC

[![Code Climate](https://codeclimate.com/github/trailofbits/dmarc.png)](https://codeclimate.com/github/trailofbits/dmarc) [![Build Status](https://travis-ci.org/trailofbits/dmarc.svg)](https://travis-ci.org/trailofbits/dmarc)
[![Gem Version](https://badge.fury.io/rb/dmarc.svg)](http://badge.fury.io/rb/dmarc)
[![YARD Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/gems/dmarc)
[![Test Coverage](https://codeclimate.com/github/trailofbits/dmarc/badges/coverage.svg)](https://codeclimate.com/github/trailofbits/dmarc)

[DMARC] is a technical specification intended to solve a couple of long-standing
email authentication problems. DMARC policies are described in DMARC "records," 
which are stored as DNS TXT records on a subdomain. This library contains a
parser for DMARC records.

## Example

Parse a DMARC record:

    require 'dmarc'

    record = DMARC::Record.parse("v=DMARC1; p=reject; rua=mailto:d@rua.agari.com; ruf=mailto:d@ruf.agari.com; fo=1")

    record.v
    # => :DMARC1

    record.adkim
    # => :r

    record.aspf
    # => :r

    record.fo
    # => ["0"]

    record.p
    # => :reject

    record.pct
    # => 100

    record.rf
    # => :afrf

    record.ri
    # => 86400

    record.rua
    # => [#<DMARC::Uri:0x0055ede60711e0 @uri=#<URI::MailTo mailto:d@rua.agari.com>, @size=nil, @unit=nil>]

    record.ruf
    # => [#<DMARC::Uri:0x0055ede606f138 @uri=#<URI::MailTo mailto:d@ruf.agari.com>, @size=nil, @unit=nil>]

    record.sp
    # => :reject

Query the DMARC record for a domain:

    record = DMARC::Record.query('twitter.com')
    # => #<DMARC::Record:0x0055ede6b808b0 @v=:DMARC1, @adkim=nil, @aspf=nil, @fo=["1"@79], @p=:reject, @pct=nil, @rf=nil, @ri=nil, @rua=[#<DMARC::Uri:0x0055ede6ba1c40 @uri=#<URI::MailTo mailto:d@rua.agari.com>, @size=nil, @unit=nil>], @ruf=[#<DMARC::Uri:0x0055ede6b8b760 @uri=#<URI::MailTo mailto:d@ruf.agari.com>, @size=nil, @unit=nil>], @sp=nil>

## Requirements

* [parslet] ~> 1.5

## Install

    $ gem install dmarc

## Testing

To run the RSpec tests:

    $ rake spec

To test the parser against the Alexa Top 500:

    $ rake spec:gauntlet

## License

See the {file:LICENSE.txt} file.

[DMARC]: https://tools.ietf.org/html/rfc7489
[parslet]: http://kschiess.github.io/parslet/
