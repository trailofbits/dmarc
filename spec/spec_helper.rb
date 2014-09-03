require 'rspec'
require 'dmarc/version'

include DMARC

RSpec.configure do |specs|
  specs.filter_run_excluding :gauntlet
end
