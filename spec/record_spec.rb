require 'spec_helper'
require 'dmarc/record'

describe Record do
  context 'by default' do
    it 'has a relaxed DKIM alignment' do
      expect(subject.adkim).to eq('r')
    end

    it 'has a relaxed SPF alignment' do
      expect(subject.aspf).to eq('r')
    end

    it 'has failure reporting options of "0"' do
      expect(subject.fo).to eq('0')
    end

    it 'has an application percentage of 100' do
      expect(subject.pct).to eq(100)
    end

    it 'has an afrf report format' do
      expect(subject.rf).to eq('afrf')
    end

    it 'has a report interval of 1 day' do
      expect(subject.ri).to eq(86400)
    end
  end

  describe '#initialize' do
    let(:parse_tree) do
      {
        v: 'DMARC1',
        p: 'none',
        adkim: 'r'
      }
    end

    it 'assigns the fields to its properties' do
      rec = described_class.new parse_tree
      expect(rec.v).to eq('DMARC1')
      expect(rec.p).to eq('none')
      expect(rec.adkim).to eq('r')
    end

    it 'gives "sp" the same value as "p" if undefined' do
      rec = described_class.new parse_tree
      expect(rec.sp).to eq('none')
    end
  end

  describe '.parse' do
    subject { described_class }

    context 'with a valid record' do
      it 'parse and returns a record' do
        rec = subject.parse('v=DMARC1; p=quarantine')

        expect(rec).to be_a Record
        expect(rec.p).to eq :quarantine
      end
    end

    context 'with an invalid record' do
      it 'raises an InvalidRecord error' do
        expect { subject.parse('v=DMARC1; foo=bar') }.to raise_error do |error|
          expect(error).to be_a InvalidRecord
          expect(error.ascii_tree).to_not be_nil
        end
      end
    end
  end

  describe ".query" do
    subject { described_class }

    context "when given a domain" do
      let(:domain) { 'google.com' }

      it "should query and parse the DMARC record" do
        record = subject.query(domain)

        expect(record).to be_kind_of(Record)
        expect(record.v).to be == :DMARC1
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
