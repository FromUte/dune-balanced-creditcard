require 'spec_helper'

describe Dune::Balanced::Creditcard::Interface do

  it 'should return the engine name' do
    expect(subject.name).to eq 'balanced-creditcard'
  end

  it 'should return account path' do
    expect(subject.account_path).to be_false
  end

  it 'should return an instance of TransactionAdditionalFeeCalculator' do
    expect(subject.fee_calculator(10)).to be_an_instance_of(Dune::Balanced::Creditcard::TransactionAdditionalFeeCalculator)
  end

  describe '#payment_path' do
    context 'when resource is a Contribution' do
      let(:resource) { mock_model('Contribution', id: 42) }

      it 'should return payment path' do
        expect(subject.payment_path(resource)).to eq Dune::Balanced::Creditcard::Engine.
            routes.url_helpers.new_payment_path(contribution_id: resource)
      end
    end

    context 'when resource is a Match' do
      let(:resource) { mock_model('Match', id: 42) }

      it 'should return payment path' do
        expect(subject.payment_path(resource)).to eq Dune::Balanced::Creditcard::Engine.
            routes.url_helpers.new_payment_path(match_id: resource)
      end
    end
  end
end

