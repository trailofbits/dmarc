require 'spec_helper'
require 'dmarc/record'

describe Record do
  describe '#initialize' do
    let(:attributes) do
      {
        v: :DMARC1,
        p: :none,
        adkim: :r
      }
    end

    subject { described_class.new(attributes) }

    it 'assigns the fields to its properties' do
      expect(subject.v).to     be :DMARC1
      expect(subject.p).to     be :none
      expect(subject.adkim).to be :r
    end

    it 'gives "sp" the same value as "p" if undefined' do
      expect(subject.sp).to be :none
    end
  end

  context 'with default values' do
    subject { described_class.new(v: :DMARC1) }

    describe "#adkim" do
      it "should return :r" do
        expect(subject.adkim).to be == :r
      end
    end

    describe "#aspf" do
      it "should return :r" do
        expect(subject.aspf).to be == :r
      end
    end

    describe "#fo" do
      it "should return ['0']" do
        expect(subject.fo).to be == ['0']
      end
    end

    describe "#pct" do
      it "should return 100" do
        expect(subject.pct).to be == 100
      end
    end

    describe "#rf" do
      it "should return afrf" do
        expect(subject.rf).to be == :afrf
      end
    end

    describe "#ri" do
      it "should return 86400" do
        expect(subject.ri).to be == 86400
      end
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
        expect {
          subject.parse('v=XXXXXXXXXX')
        }.to raise_error(InvalidRecord)
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
        expect(subject.query('foobar.com')).to be_nil
      end
    end
  end

  shared_examples "question mark method" do |field,value|
    describe "#{field}?" do
      context "when #{field} is set" do
        subject do
          described_class.new(v: :DMARC1, field => value)
        end

        it { expect(subject.send(:"#{field}?")).to be(true) }
      end

      context "when #{field} is omitted" do
        subject { described_class.new(v: :DMARC1) }

        it { expect(subject.send(:"#{field}?")).to be(false) }
      end
    end
  end

  include_examples "question mark method", :adkim, :r
  include_examples "question mark method", :aspf, :r
  include_examples "question mark method", :fo, %w[0 1 d]
  include_examples "question mark method", :p, :reject
  include_examples "question mark method", :pct, 100
  include_examples "question mark method", :rf, :afrf
  include_examples "question mark method", :ri, 86400
  include_examples "question mark method", :rua, [URI("mailto:bob@example.com")]
  include_examples "question mark method", :ruf, [URI("mailto:bob@example.com")]
  include_examples "question mark method", :sp, :reject

  describe "#sp?" do
    context "when sp is set" do
    end
  end

  describe "#to_h" do
    let(:v) { :DMARC1 }
    let(:p) { :reject }
    let(:rua) { [URI.parse('mailto:d@rua.agari.com')] }
    let(:ruf) { [URI.parse('mailto:d@rua.agari.com')] }
    let(:fo)  { %w[0 1 d] }

    subject do
      described_class.new(
        v: v,
        p: p,
        rua: rua,
        ruf: ruf,
        fo: fo
      )
    end

    it "should return a Hash" do
      expect(subject.to_h).to be_kind_of(Hash)
    end

    it "should only include fields that have values" do
      expect(subject.to_h).to be == {
        v: v,
        p: p,
        rua: rua,
        ruf: ruf,
        fo: fo
      }
    end
  end

  describe "#to_s" do
    let(:v) { :DMARC1 }
    let(:p) { :reject }
    let(:rua) { [URI.parse('mailto:d@rua.agari.com')] }
    let(:ruf) { [URI.parse('mailto:d@rua.agari.com')] }
    let(:rf)  { %w[afrf iodef] }
    let(:fo)  { %w[0 1 d] }

    subject do
      described_class.new(
        v: v,
        p: p,
        rua: rua,
        ruf: ruf,
        rf: rf,
        fo: fo
      )
    end

    it "should convert the record to a String" do
      expect(subject.to_s).to be == "v=#{v}; p=#{p}; rua=#{rua[0]}; ruf=#{ruf[0]}; rf=#{rf[0]},#{rf[1]}; fo=#{fo[0]}:#{fo[1]}:#{fo[2]}"      
    end
  end
end
