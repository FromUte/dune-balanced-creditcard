require 'spec_helper'

describe Neighborly::Balanced::Payment do
  let(:customer)     { double('::Balanced::Customer') }
  let(:contribution) { double('Contribution', value: 1234).as_null_object }
  let(:debit)        { double('::Balanced::Debit').as_null_object }
  let(:attributes)   { { use_card: 'my-new-card' } }
  subject do
    described_class.new('balanced-creditcard',
                        customer,
                        contribution,
                        attributes)
  end

  describe "contribution amount in cents" do
    context "when customer is paying fees" do
      let(:attributes) { { pay_fee: '1', use_card: 'my-new-card' } }

      it "returns net amount from TransactionAdditionalFeeCalculator" do
        Neighborly::Balanced::Creditcard::TransactionAdditionalFeeCalculator.
          any_instance.stub(:net_amount).and_return(15)
        expect(subject.contribution_amount_in_cents).to eql(1500)
      end
    end

    context "when customer is not paying fees" do
      let(:attributes) { { pay_fee: '0', use_card: 'my-new-card' } }

      it "returns net amount from TransactionInclusiveFeeCalculator" do
        Neighborly::Balanced::Creditcard::TransactionInclusiveFeeCalculator.
          any_instance.stub(:net_amount).and_return(10)
        expect(subject.contribution_amount_in_cents).to eql(1000)
      end
    end
  end

  describe "checkout" do
    context "when customer is paying fees" do
      let(:attributes) { { pay_fee: '1', use_card: 'my-new-card' } }

      it "debits customer with contribution amount in cents" do
        subject.stub(:contribution_amount_in_cents).and_return(1000)
        customer.should_receive(:debit).
                 with(hash_including(amount: 1000)).
                 and_return(debit)
        subject.checkout!
      end
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

      it "defines given engine's name as payment method of the contribution" do
        contribution.should_receive(:update_attributes).
                     with(hash_including(payment_method: 'balanced-creditcard'))
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

      it "defines given engine's name as payment method of the contribution" do
        contribution.should_receive(:update_attributes).
                     with(hash_including(payment_method: 'balanced-creditcard'))
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
