require 'spec_helper'
require 'dmarc/uri'

describe DMARC::Uri do
  let(:uri)  { URI("mailto:d@ruf.agari.com") }
  let(:size) { 10 }
  let(:unit) { :m }

  subject { described_class.new(uri,size,unit) }

  describe "#initialize" do
    it "should set the uri" do
      expect(subject.uri).to be uri
    end

    it "should set the size" do
      expect(subject.size).to be size
    end

    it "should set the unit" do
      expect(subject.unit).to be unit
    end

    context "when size is omitted" do
      subject { described_class.new(uri) }

      it "should set size to nil" do
        expect(subject.size).to be(nil)
      end

      it "should set unit to nil" do
        expect(subject.unit).to be(nil)
      end
    end

    context "when unit is omitted" do
      subject { described_class.new(uri,size) }

      it "should set size" do
        expect(subject.size).to be(size)
      end

      it "should set unit to nil" do
        expect(subject.unit).to be(nil)
      end
    end
  end

  describe "#size?" do
    context "when size is nil" do
      subject { described_class.new(uri) }

      it { expect(subject.size?).to be(false) }
    end

    context "when size is set" do
      subject { described_class.new(uri,size) }

      it { expect(subject.size?).to be(true) }
    end
  end

  describe "#unit?" do
    context "when unit is nil" do
      subject { described_class.new(uri,size) }

      it { expect(subject.unit?).to be(false) }
    end

    context "when unit is set" do
      subject { described_class.new(uri,size,unit) }

      it { expect(subject.unit?).to be(true) }
    end
  end

  describe "#==" do
    context "when other is a #{described_class}" do
      context "and all fields match" do
        let(:other) { described_class.new(uri.dup,size,unit) }

        it { expect(subject == other).to be(true) }
      end

      context "but the uri is different" do
        let(:other_uri) { URI("mailto:foo@example.com")            }
        let(:other)     { described_class.new(other_uri,size,unit) }

        it { expect(subject == other).to be(false) }
      end

      context "but the size is different" do
        let(:other) { described_class.new(uri,42,unit) }

        it { expect(subject == other).to be(false) }
      end

      context "but the unit is different" do
        let(:other) { described_class.new(uri,size,:t) }

        it { expect(subject == other).to be(false) }
      end
    end

    context "when other is a different class" do
      let(:other) { Object.new }

      it { expect(subject == other).to be(false) }
    end
  end

  describe "#to_s" do
    context "when only the uri is set" do
      subject { described_class.new(uri) }

      it "should return the uri" do
        expect(subject.to_s).to be == uri.to_s
      end
    end

    context "when uri and size are set" do
      subject { described_class.new(uri,size) }

      it "should return the uri!size" do
        expect(subject.to_s).to be == "#{uri}!#{size}"
      end
    end

    context "when uri, size and unit are set" do
      it "should return the uri!size" do
        expect(subject.to_s).to be == "#{uri}!#{size}#{unit}"
      end
    end
  end

  describe "#method_missing" do
    it "should pass through methods to uri" do
      expect(subject.host).to be(uri.host)
    end
  end
end
