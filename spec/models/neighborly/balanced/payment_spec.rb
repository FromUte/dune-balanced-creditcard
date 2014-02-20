require 'spec_helper'

describe Neighborly::Balanced::Payment do
  let(:customer)     { double('::Balanced::Customer') }
  let(:contribution) { double('Contribution', price_in_cents: 1234).as_null_object }
  let(:attributes)   { { use_card: 'my-new-card' } }
  subject { described_class.new(customer, contribution, attributes) }

  describe "checkout" do
    it "debits customer with price in cents" do
      customer.should_receive(:debit).with(hash_including(amount: 1234))
      subject.checkout!
    end

    it "debits customer on selected funding instrument" do
      customer.should_receive(:debit).with(hash_including(source_uri: 'my-new-card'))
      subject.checkout!
    end
  end

  describe "successful state" do
    let(:debit) { double('::Balanced::Debit') }
    before do
      customer.stub(:debit).and_return(debit)
    end

    context "after checkout" do
      before { subject.checkout! }

      it "is successfull when the debit has 'succeeded' status" do
        debit.stub(:status).and_return('succeeded')
        expect(subject).to be_successful
      end

      it "is successfull when the debit has 'pending' status" do
        debit.stub(:status).and_return('pending')
        expect(subject).to be_successful
      end

      it "is not successfull when the debit has others statuses" do
        debit.stub(:status).and_return('failed')
        expect(subject).to_not be_successful
      end
    end

    context "before checkout" do
      it "is not successfull" do
        expect(subject).to_not be_successful
      end
    end
  end
end
