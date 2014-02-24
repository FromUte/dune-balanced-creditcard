require 'spec_helper'

describe Neighborly::Balanced::Payment do
  let(:customer)     { double('::Balanced::Customer') }
  let(:contribution) { double('Contribution', price_in_cents: 1234).as_null_object }
  let(:debit)        { double('::Balanced::Debit').as_null_object }
  let(:attributes)   { { use_card: 'my-new-card' } }
  subject { described_class.new(customer, contribution, attributes) }

  describe "checkout" do
    it "debits customer with price in cents" do
      customer.should_receive(:debit).
               with(hash_including(amount: 1234)).
               and_return(debit)
      subject.checkout!
    end

    it "debits customer on selected funding instrument" do
      customer.should_receive(:debit).
               with(hash_including(source: 'my-new-card')).
               and_return(debit)
      subject.checkout!
    end

    context "with successful debit" do
      before { customer.stub(:debit).and_return(debit) }

      it "confirms the contribution" do
        expect(contribution).to receive(:confirm!)
        subject.checkout!
      end

      it "defines id as payment id of the contribution" do
        debit.stub(:id).and_return('i-am-an-id!')
        contribution.should_receive(:update_attributes).
                     with(hash_including(payment_id: 'i-am-an-id!'))
        subject.checkout!
      end

      it "defines 'balanced' as payment method of the contribution" do
        contribution.should_receive(:update_attributes).
                     with(hash_including(payment_method: :balanced))
        subject.checkout!
      end

      it "defines 'creditcard' as payment choice of the contribution" do
        contribution.should_receive(:update_attributes).
                     with(hash_including(payment_choice: :creditcard))
        subject.checkout!
      end
    end

    context "when raising Balanced::PaymentRequired exception" do
      before do
        customer.stub(:debit).and_raise(Balanced::PaymentRequired.new({}))
      end

      it "cancels the contribution" do
        expect(contribution).to receive(:cancel!)
        subject.checkout!
      end

      it "defines 'balanced' as payment method of the contribution" do
        contribution.should_receive(:update_attributes).
                     with(hash_including(payment_method: :balanced))
        subject.checkout!
      end

      it "defines 'creditcard' as payment choice of the contribution" do
        contribution.should_receive(:update_attributes).
                     with(hash_including(payment_choice: :creditcard))
        subject.checkout!
      end
    end
  end

  describe "successful state" do
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
