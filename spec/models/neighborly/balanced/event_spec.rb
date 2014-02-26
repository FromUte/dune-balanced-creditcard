require 'spec_helper'

describe Neighborly::Balanced::Event do
  subject { described_class.new(params) }
  let(:contribution) { double('Contribution', id: 49) }
  let(:params) do
    fixture = Rails.root.join('..', '..', 'spec', 'fixtures', 'notifications', 'debit_created.yml')
    YAML.load(File.read(fixture)).with_indifferent_access
  end

  describe "validability" do
    before { subject.stub(:contribution).and_return(contribution) }

    context "when contribution exists" do
      context "when its value and payment matches" do
        before do
          contribution.stub(:price_in_cents).and_return(params[:entity][:amount].to_i)
        end

        it { should be_valid }
      end

      context "when value does not match with payment" do
        before do
          contribution.stub(:price_in_cents).and_return((params[:entity][:amount]+1).to_i)
        end

        it { should_not be_valid }
      end
    end

    context "when no contribution does not exist" do
      let(:contribution) { nil }

      it { should_not be_valid }
    end
  end

  context "with debit.created params" do
    let(:params) do
      fixture = Rails.root.join('..', '..', 'spec', 'fixtures', 'notifications', 'debit_created.yml')
      YAML.load(File.read(fixture)).with_indifferent_access
    end

    it "creates a new payment notification" do
      subject.stub(:contribution).and_return(contribution)
      expect(PaymentEngines).to receive(:create_payment_notification).
        with(hash_including(contribution_id: contribution.id))
      subject.save
    end

    it "stores metadata of event" do
      expect(PaymentEngines).to receive(:create_payment_notification).
        with(hash_including(:extra_data))
      subject.save
    end
  end

  context "with debit.succeeded params" do
    let(:params) do
      fixture = Rails.root.join('..', '..', 'spec', 'fixtures', 'notifications', 'debit_succeeded.yml')
      YAML.load(File.read(fixture)).with_indifferent_access
    end

    it "creates a new payment notification" do
      subject.stub(:contribution).and_return(contribution)
      expect(PaymentEngines).to receive(:create_payment_notification).
        with(hash_including(contribution_id: contribution.id))
      subject.save
    end

    it "stores metadata of event" do
      expect(PaymentEngines).to receive(:create_payment_notification).
        with(hash_including(:extra_data))
      subject.save
    end
  end
end
