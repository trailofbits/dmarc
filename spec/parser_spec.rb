require 'spec_helper'
require 'dmarc/parser'

describe Parser do
  describe '#dmarc_uri' do
    subject { described_class.new.dmarc_uri }

    let(:uri) { 'mailto:user@example.org' }

    it 'parses mailto URIs' do
      expect(subject.parse(uri)).to eq(uri: uri)
    end

    it 'parses mailto URIs with size' do
      expect(subject.parse(uri + '!20')).to eq(uri: uri, size: '20')
    end

    it 'parses mailto URIs with size and unit' do
      expect(subject.parse(uri + '!20k')).to eq(uri: uri, size: '20', unit: 'k')
    end
  end

  describe '#dmarc_record' do
    subject { described_class.new.dmarc_record }

    it 'parses version and policy' do
      record = 'v=DMARC1;p=none'
      expect(subject.parse record).to eq(
        v: 'DMARC1',
        p: 'none',
      )
    end

    it 'parses version, policy, and other tags' do
      record = 'v=DMARC1;p=none;sp=reject;adkim=r;aspf=r'
      expect(subject.parse record).to eq(
        v: 'DMARC1',
        p: 'none',
        sp: 'reject',
        adkim: 'r',
        aspf: 'r',
      )
    end

    it 'parses version, policy, and rua' do
      record = 'v=DMARC1;p=quarantine;rua=mailto:foo@example.com,mailto:bar@example.com'
      expect(subject.parse record).to eq(
        v: 'DMARC1',
        p: 'quarantine',
        rua: [
          {uri: 'mailto:foo@example.com'},
          {uri: 'mailto:bar@example.com'}
        ]
      )
    end

    it "parses yahoo's dmarc record (as of 2014/08/12)" do
      record = 'v=DMARC1; p=reject; sp=none; pct=100; rua=mailto:dmarc-yahoo-rua@yahoo-inc.com, mailto:dmarc_y_rua@yahoo.com;'
      expect(subject.parse record).to eq(
        v: 'DMARC1',
        p: 'reject',
        sp: 'none',
        pct: '100',
        rua: [
          {uri: 'mailto:dmarc-yahoo-rua@yahoo-inc.com'},
          {uri: 'mailto:dmarc_y_rua@yahoo.com'}
        ]
      )
    end

    it 'ignores spacing' do
      record1 = 'v=DMARC1;p=none;sp=reject'
      record2 = 'v = DMARC1 ; p = none ; sp = reject'
      expect(subject.parse record1).to eq(subject.parse record2)
    end
  end

  describe '#dmarc_version' do
    subject { described_class.new.dmarc_version }

    it 'parses DMARC versions' do
      expect(subject.parse('v=DMARC1')).to eq(v: 'DMARC1')
    end

    it 'ignores spacing' do
      expect(subject.parse 'v = DMARC1').to eq(subject.parse 'v=DMARC1')
    end
  end

  describe '#dmarc_request' do
    subject { described_class.new.dmarc_request }

    it 'parses "none" requests' do
      expect(subject.parse('p=none')).to eq(p: 'none')
    end

    it 'parses quarantine requests' do
      expect(subject.parse('p=quarantine')).to eq(p: 'quarantine')
    end

    it 'parses reject requests' do
      expect(subject.parse('p=reject')).to eq(p: 'reject')
    end

    it 'ingores spacing' do
      expect(subject.parse 'p=none').to eq(subject.parse 'p = none')
    end
  end

  describe '#dmarc_srequest' do
    subject { described_class.new.dmarc_srequest }

    it 'parses "none" requests' do
      expect(subject.parse('sp=none')).to eq(sp: 'none')
    end

    it 'parses quarantine requests' do
      expect(subject.parse('sp=quarantine')).to eq(sp: 'quarantine')
    end

    it 'parses reject requests' do
      expect(subject.parse('sp=reject')).to eq(sp: 'reject')
    end

    it 'ignores spacing' do
      expect(subject.parse 'sp=none').to eq(subject.parse 'sp = none')
    end
  end

  describe '#dmarc_auri' do
    subject { described_class.new.dmarc_auri }

    it 'parses one URI' do
      expect(subject.parse('rua=mailto:user@example.org')).to eq(
        rua: {
          uri: 'mailto:user@example.org'
        }
      )
    end

    it 'parses many URIs' do
      expect(
        subject.parse('rua = mailto:user1@example.org, mailto:user2@example.org')
      ).to eq(
        rua: [
          {uri: 'mailto:user1@example.org'},
          {uri: 'mailto:user2@example.org'}
        ]
      )
    end

    it 'parses maximum report size' do
      expect(subject.parse('rua = mailto:user1@example.com!20m')).to eq(
        rua: {
          uri: 'mailto:user1@example.com',
          size: '20',
          unit: 'm'
        }
      )
    end
  end

  describe '#dmarc_ainterval' do
    subject { described_class.new.dmarc_ainterval }

    it 'parses a one digit interval' do
      expect(subject.parse('ri=1')).to eq(ri: '1')
    end

    it 'parses a many digit interval' do
      expect(subject.parse('ri=86400')).to eq(ri: '86400')
    end

    it 'ignores spacing' do
      expect(subject.parse 'ri = 86400').to eq(subject.parse 'ri=86400')
    end
  end

  describe '#dmarc_furi' do
    subject { described_class.new.dmarc_furi }

    it 'parses one URI' do
      expect(subject.parse('ruf=mailto:user@example.org')).to eq(
        ruf: {
          uri: 'mailto:user@example.org'
        }
      )
    end

    it 'parses many URIs' do
      expect(
        subject.parse('ruf = mailto:user1@example.org, mailto:user2@example.org')
      ).to eq(
        ruf: [
          {uri: 'mailto:user1@example.org'},
          {uri: 'mailto:user2@example.org'}
        ]
      )
    end

    it 'parses maximum report size' do
      expect(subject.parse('ruf = mailto:user1@example.com!20m')).to eq(
        ruf: {
          uri: 'mailto:user1@example.com',
          size: '20',
          unit: 'm'
        }
      )
    end
  end

  describe '#dmarc_fo' do
    let(:fo) { described_class.new.dmarc_fo }

    context 'one value' do
      %w[0 1 d s].each do |value|
        it "parses #{value}" do
          expect(fo.parse("fo=#{value}")).to eq(fo: value)
        end
      end
    end

    it 'parses many values' do
      expect(fo.parse('fo=0:1:d:s')).to eq([
        {fo: '0'},
        {fo: '1'},
        {fo: 'd'},
        {fo: 's'}
      ])
    end
  end

  describe '#dmarc_rfmt' do
    subject { described_class.new.dmarc_rfmt }

    it 'parses afrf format' do
      expect(subject.parse('rf=afrf')).to eq(rf: 'afrf')
    end

    it 'parses iodef format' do
      expect(subject.parse('rf=iodef')).to eq(rf: 'iodef')
    end

    it 'ignores spacing' do
      expect(subject.parse 'rf=iodef').to eq(subject.parse 'rf = iodef')
    end
  end

  describe '#dmarc_percent' do
    subject { described_class.new.dmarc_percent }

    it 'parses a one-digit percent' do
      expect(subject.parse('pct=1')).to eq(pct: '1')
    end

    it 'parses a two-digit percent' do
      expect(subject.parse('pct=10')).to eq(pct: '10')
    end

    it 'parses a three-digit percent' do
      expect(subject.parse('pct=100')).to eq(pct: '100')
    end

    it 'ignores spacing' do
      expect(subject.parse 'pct = 100').to eq(subject.parse 'pct=100')
    end
  end

  describe '#dmarc_adkim' do
    subject { described_class.new.dmarc_adkim }

    it 'parses a relaxed DKIM policy' do
      expect(subject.parse('adkim=r')).to eq(adkim: 'r')
    end

    it 'parses a strict DKIM policy' do
      expect(subject.parse('adkim=s')).to eq(adkim: 's')
    end

    it 'ignores spacing' do
      expect(subject.parse 'adkim=r').to eq(subject.parse 'adkim = r')
    end
  end

  describe '#dmarc_aspf' do
    subject { described_class.new.dmarc_aspf }

    it 'parses a relaxed SPF policy' do
      expect(subject.parse('aspf=r')).to eq(aspf: 'r')
    end

    it 'parses a strict SPF policy' do
      expect(subject.parse('aspf=s')).to eq(aspf: 's')
    end

    it 'ignores spacing' do
      expect(subject.parse 'aspf=s').to eq(subject.parse 'aspf = s')
    end
  end
end
