dmarc
=====

[DMARC](http://tools.ietf.org/html/draft-kucherawy-dmarc-base-02) is a
technical specification intended to solve a couple of long-standing email
authentication problems. DMARC policies are described in DMARC "records," which
are stored as DNS TXT records on a subdomain. This library contains a parser
for DMARC records.

Usage
-----

```ruby
require 'dmarc/record'
record = DMARC::Record.from_txt(txt) # txt is a DNS TXT record containing the DMARC policy
```

