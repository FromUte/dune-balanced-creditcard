require 'spec_helper'

describe Neighborly::Balanced::Creditcard::UsersController do
  let(:customer_uri)   { 42 }
  let(:creditcard_uri) { 43 }

  describe "POST 'creditcard'" do
    let(:customer) { double(Balanced::Customer) }
    before do
      Balanced::Customer.find(customer_uri).and_return(customer)
    end

    it "attachs a creditcard to a customer on Balanced" do
      expect(customer).to receive(:add_card).with(creditcard_uri)
      post :creditcard, uri: customer_uri, creditcard_uri: creditcard_uri
    end

    context "with successful response from Balanced" do
      before do
        Balanced::Customer.any_instance.stub(:add_card).and_return(customer)
      end

      it "responds with 200 HTTP status" do
        post :creditcard, uri: customer_uri, creditcard_uri: creditcard_uri
        expect(response.status).to eql(200)
      end
    end

    context "without successful response from Balanced" do
      before do
        Balanced::Customer.any_instance.stub(:add_card).and_return do
          raise Balanced::Conflict
        end
      end

      it "responds with 400 HTTP status" do
        post :creditcard, uri: customer_uri, creditcard_uri: creditcard_uri
        expect(response.status).to eql(400)
      end
    end
  end
end
