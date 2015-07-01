### 0.3.0 / 2015-07-01

* Added {DMARC::Record.query}.
* Added {DMARC::Record#to_s}.
* Added {DMARC::InvalidRecord}.
* Deprecate {DMARC::Record.from_txt}.
* {DMARC::Record#v} now returns `:DMARC1`.
* {DMARC::Record#p} and {DMARC::Record#sp} now return Symbols
* {DMARC::Record#rua} and {DMARC::Record#ruf} will always return Arrays.
* Fixed a bug in {DMARC::Parser} with respect to order of tags.
* {DMARC::Parser::Transform} now coerces URIs into URI objects.

### 0.2.0 / 2014-10-20

* Added `DMARC::Error`.
* Added {DMARC::InvalidRecord}.
* Add support for parsing `fo` tokens.
* Ignore unknown tags instead of raising a parser exception.
* Ignore tags with invalid values instead of raising a parser exception.

### 0.1.0 / 2014-04-25

* Initial release.

