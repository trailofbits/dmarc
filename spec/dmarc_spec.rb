require 'spec_helper'
require 'dmarc'

describe DMARC do
  describe ".query" do
    context "when given a domain" do
      let(:domain) { 'google.com' }

      it "should query and parse the DMARC record" do
        record = subject.query(domain)

        expect(record).to be_kind_of(Record)
        expect(record.v).to be == 'DMARC1'
      end
    end

    context "when given a bad domain" do
      it "should raise a DNS error" do
        expect {
          subject.query('foobar.com')
        }.to raise_error
      end
    end
  end
end
