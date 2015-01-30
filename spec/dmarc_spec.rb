require 'spec_helper'
require 'dmarc'

describe DMARC do
  subject { described_class }

  describe ".query" do
    context "when given a domain" do
      let(:domain) { 'google.com' }

      it "should query and parse the DMARC record" do
        record = subject.query(domain)

        expect(record).to be == 'v=DMARC1; p=quarantine; rua=mailto:mailauth-reports@google.com'
      end
    end

    context "when given a bad domain" do
      it "should raise a DNS error" do
        expect(subject.query('foobar.com')).to be_nil
      end
    end
  end
end
