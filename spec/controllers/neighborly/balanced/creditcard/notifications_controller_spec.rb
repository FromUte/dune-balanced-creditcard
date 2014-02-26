require 'spec_helper'

describe Neighborly::Balanced::Creditcard::NotificationsController do
  routes { Neighborly::Balanced::Creditcard::Engine.routes }
  let(:event) { double('Event') }
  let(:debit_created_params) do
    fixture = Rails.root.join('..', '..', 'spec', 'fixtures', 'notifications', 'debit_created.yml')
    YAML.load(File.read(fixture))
  end
  let(:debit_succeeded_params) do
    fixture = Rails.root.join('..', '..', 'spec', 'fixtures', 'notifications', 'debit_succeeded.yml')
    YAML.load(File.read(fixture))
  end

  describe "POST 'create'" do
    context "with debit.created notification" do
      let(:params) { debit_created_params }

      it "saves a new event" do
        expect_any_instance_of(Neighborly::Balanced::Event).to receive(:save)
        post :create, params
      end

      context "with valid event" do
        before do
          Neighborly::Balanced::Event.any_instance.stub(:valid?).and_return(true)
        end

        it "responds with 200 http status" do
          post :create, params
          expect(response.status).to eql(200)
        end
      end

      context "with invalid event" do
        before do
          Neighborly::Balanced::Event.any_instance.stub(:valid?).and_return(false)
        end

        it "responds with 400 http status" do
          post :create, params
          expect(response.status).to eql(400)
        end
      end
    end

    context "with debit.succeeded notification" do
      let(:params) { debit_succeeded_params }

      it "saves a new event" do
        expect_any_instance_of(Neighborly::Balanced::Event).to receive(:save)
        post :create, params
      end

      context "with valid event" do
        before do
          Neighborly::Balanced::Event.any_instance.stub(:valid?).and_return(true)
        end

        it "responds with 200 http status" do
          post :create, params
          expect(response.status).to eql(200)
        end
      end

      context "with invalid event" do
        before do
          Neighborly::Balanced::Event.any_instance.stub(:valid?).and_return(false)
        end

        it "responds with 400 http status" do
          post :create, params
          expect(response.status).to eql(400)
        end
      end
    end
  end
end
