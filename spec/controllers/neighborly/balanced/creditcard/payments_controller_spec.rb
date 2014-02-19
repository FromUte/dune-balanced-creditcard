require 'spec_helper'

describe Neighborly::Balanced::Creditcard::PaymentsController do
  routes { Neighborly::Balanced::Creditcard::Engine.routes }
  let(:customer) do
    double('::Balanced::Customer',
           cards: [],
           uri:   '/qwertyuiop').as_null_object
  end

  before do
    ::Balanced::Customer.stub(:find).and_return(customer)
    ::Balanced::Customer.stub(:new).and_return(customer)
  end

  describe "GET 'new'" do
    let(:current_user) { double('User').as_null_object }
    before do
      controller.stub(:current_user).and_return(current_user)
    end

    context "when user already has a balanced_contributor associated" do
      before do
        contributor = double('Neighborly::Balanced::Creditcard::Contributor',
                             uri: '/qwertyuiop')
        current_user.stub(:balanced_contributor).
                     and_return(contributor)
      end

      it "skips creation of new costumer" do
        customer.should_receive(:save).never
        get :new, contribution_id: 42
      end
    end

    context "when user don't has balanced_contributor associated" do
      before do
        current_user.stub(:balanced_contributor)
      end

      it "saves a new costumer" do
        customer.should_receive(:save)
        get :new, contribution_id: 42
      end

      it "defines user_id in the meta data of the costumer" do
        customer_attrs = hash_including(meta: hash_including(:user_id))
        ::Balanced::Customer.should_receive(:new).with(customer_attrs)
        get :new, contribution_id: 42
      end
    end
  end
end
