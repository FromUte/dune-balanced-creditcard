require 'spec_helper'

describe Neighborly::Balanced::Creditcard::PaymentsController do
  routes { Neighborly::Balanced::Creditcard::Engine.routes }

  describe "GET 'new'" do
    let(:current_user) { stub_model(User) }
    before do
      controller.stub(:current_user).and_return(current_user)
    end

    context "when user already has a balanced_contributor associated" do
      it "saves a new costumer" do
        ::Balanced::Customer.any_instance.should_receive(:save)
        get :new, contribution_id: 42
      end

      it "defines user_id in the meta data of the costumer" do
        customer_attrs = hash_including(meta: hash_including(:user_id))
        ::Balanced::Customer.should_receive(:new).with(customer_attrs)
        get :new, contribution_id: 42
      end
    end

    context "when user don't has balanced_contributor associated" do
      it "skips creation of new costumer" do
        ::Balanced::Customer.any_instance.should_receive(:save).never
        get :new, contribution_id: 42
      end
    end
  end
end
