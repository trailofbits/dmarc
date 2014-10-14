dmarc
=====

[![Code Climate](https://codeclimate.com/github/trailofbits/dmarc.png)](https://codeclimate.com/github/trailofbits/dmarc) [![Build Status](https://travis-ci.org/trailofbits/dmarc.svg)](https://travis-ci.org/trailofbits/dmarc)
[![Gem Version](https://badge.fury.io/rb/dmarc.svg)](http://badge.fury.io/rb/dmarc)

[DMARC] is a technical specification intended to solve a couple of long-standing
email authentication problems. DMARC policies are described in DMARC "records," 
which are stored as DNS TXT records on a subdomain. This library contains a
parser for DMARC records.

Example
-------

    require 'dmarc/record'
    record = DMARC::Record.from_txt(txt) # txt is a DNS TXT record containing the DMARC policy

Requirements
------------

* [parslet] ~> 1.5

Install
-------

    $ gem install dmarc

Testing
-------

To run the RSpec tests:

    $ rake spec

To test the parser against the Alexa Top 500:

    $ rake spec:gauntlet

License
-------

See the {file:LICENSE.txt} file.

[DMARC]: http://tools.ietf.org/html/draft-kucherawy-dmarc-base-02
[parslet]: http://kschiess.github.io/parslet/
