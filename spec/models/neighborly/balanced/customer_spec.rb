require 'spec_helper'

describe Neighborly::Balanced::Customer do
  let(:user)    { double('User').as_null_object }
  let(:update_address) { '1' }
  let(:params)  { ActionController::Parameters.new( {
                  payment: {
                     user: { name:              'Name',
                             address_street:    '',
                             address_city:      '',
                             address_state:     '',
                             address_zip_code:  '',
                             update_address:    update_address } }
  } ) }

  let(:balanced_customer) do
    double('::Balanced::Customer', uri: '/qwertyuiop').as_null_object
  end

  before do
    ::Balanced::Customer.stub(:find).and_return(balanced_customer)
    ::Balanced::Customer.stub(:new).and_return(balanced_customer)
  end

  subject { Neighborly::Balanced::Customer.new(user, params) }

  describe '#fetch' do
    context 'when user already has a balanced_contributor associated' do
      before do
        contributor = double('Neighborly::Balanced::Creditcard::Contributor',
                             uri: '/qwertyuiop')
        user.stub(:balanced_contributor).
                  and_return(contributor)
      end

      it 'skips creation of new costumer' do
        subject.fetch
      end
    end

    context "when user don't has balanced_contributor associated" do
      before do
        user.stub(:balanced_contributor)
      end

      it 'saves a new costumer' do
        expect(balanced_customer).to receive(:save)
        subject.fetch
      end

      it 'defines user_id in the meta data of the costumer' do
        customer_attrs = hash_including(meta: hash_including(:user_id))
        ::Balanced::Customer.should_receive(:new).with(customer_attrs)
        subject.fetch
      end
    end

    describe '#update!' do
      describe 'update of user attributes' do
        context "reflects attributes in user's resource when update_address option is checked" do
          let(:update_address) { '1' }
          before { expect(user).to receive(:update!) }
          it { subject.update! }

        end

        context "skips update of user's resource when update_address option is not checked" do
          let(:update_address) { '0' }
          before { expect(user).to_not receive(:update!).with {} }
          it { subject.update! }
        end
      end

      describe 'update balanced customer' do
        before { expect(balanced_customer).to receive(:save) }
        it { subject.update! }
      end
    end
  end
end
