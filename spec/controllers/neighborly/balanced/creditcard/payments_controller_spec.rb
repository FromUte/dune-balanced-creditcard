require 'spec_helper'

describe Neighborly::Balanced::Creditcard::PaymentsController do
  routes { Neighborly::Balanced::Creditcard::Engine.routes }
  let(:current_user) { double('User').as_null_object }
  let(:customer) do
    double('::Balanced::Customer',
           cards: [],
           uri:   '/qwertyuiop').as_null_object
  end

  before do
    ::Balanced::Customer.stub(:find).and_return(customer)
    ::Balanced::Customer.stub(:new).and_return(customer)
    controller.stub(:authenticate_user!)
    controller.stub(:current_user).and_return(current_user)
    Neighborly::Balanced::Creditcard::Payment.any_instance.stub(:meta).and_return({})
  end

  describe 'GET \'new\'' do
    shared_examples_for '#new' do
      it 'should fetch balanced customer' do
        expect_any_instance_of(Neighborly::Balanced::Customer).to receive(:fetch).and_return(customer)
        get :new, params
      end

      it 'should receive authenticate_user!' do
        expect(controller).to receive(:authenticate_user!)
        get :new, params
      end
    end

    context 'when params is contribution_id' do
      let(:params) do
        { contribution_id: 42 }
      end

      it_should_behave_like '#new'
    end

    context 'when params is projects_match_id' do
      let(:params) do
        { projects_match_id: 42 }
      end

      it_should_behave_like '#new'
    end
  end

  describe 'POST \'create\'' do
    shared_examples_for '#create' do
      let(:user) do
        double('User', balanced_contributor: double('BalancedContributor',
                                                    uri: 'project-owner-uri'))
      end

      let(:project) do
        double('Project', permalink: 'thirty-three', user: user).as_null_object
      end

      let(:params) do
        {
          'payment' => {
            'use_card'        => '443',
            resource_id_name => '42',
            'user'            => {}
          },
        }
      end

      before do
        resource.stub(:id).and_return(42)
        resource.stub(:project).and_return(project)

        Neighborly::Balanced::Creditcard::Payment.any_instance.stub(:project_owner_customer).
          and_return(double('::Balanced::Customer', uri: 'project-owner-uri'))
      end

      it 'should receive authenticate_user!' do
        expect(controller).to receive(:authenticate_user!)
        post :create, params
      end

      it 'generates new payment with given params' do
        Neighborly::Balanced::Creditcard::Payment.should_receive(:new).
          with(anything, customer, an_instance_of(resource.class), params['payment']).
          and_return(double('Payment').as_null_object)
        post :create, params
      end

      it 'generates new payment with engine\'s name given' do
        Neighborly::Balanced::Creditcard::Payment.should_receive(:new).
          with('balanced-creditcard', anything, anything, anything).
          and_return(double('Payment').as_null_object)
        post :create, params
      end

      it 'checkouts payment of resource' do
        Neighborly::Balanced::Creditcard::Payment.any_instance.should_receive(:checkout!)
        post :create, params
      end

      describe 'insertion of card on customer account' do
        let(:customer) { double('::Balanced::Customer').as_null_object }
        let(:card) do
          double('::Balanced::Card', id: params['payment']['use_card'])
        end
        before do
          controller.stub(:customer).and_return(customer)
        end

        context 'customer doesn\'t have the given card' do
          before do
            customer.stub(:cards).and_return([])
          end

          it 'inserts to customer\'s card list' do
            expect(customer).to receive(:add_card).with(card.id)
            post :create, params
          end
        end

        context 'customer already has the card' do
          before do
            customer.stub(:cards).and_return([card])
          end

          it 'skips insertion' do
            expect(customer).to_not receive(:add_card)
            post :create, params
          end
        end
      end

      describe 'update customer' do
        it 'update user attributes and balanced customer' do
          expect_any_instance_of(Neighborly::Balanced::Customer).to receive(:update!)
          post :create, params
        end
      end

      context 'with successul checkout' do
        before do
          Neighborly::Balanced::Creditcard::Payment.any_instance.
                                        stub(:successful?).
                                        and_return(true)
        end

        it 'redirects to resource page' do
          resource.class.stub(:find).with('42').and_return(resource)
          post :create, params
          expect(response).to redirect_to(resource_path)
        end
      end

      context 'with unsuccessul checkout' do
        before do
          Neighborly::Balanced::Creditcard::Payment.any_instance.
                                        stub(:successful?).
                                        and_return(false)
        end

        it 'redirects to resource edit page' do
          resource.class.stub(:find).with('42').and_return(resource)
          post :create, params
          expect(response).to redirect_to(edit_resource_path)
        end
      end
    end

    context 'when resource is Contribution' do
      let(:resource)           { Contribution.new }
      let(:resource_id_name)   { 'contribution_id' }
      let(:resource_path)      { '/projects/thirty-three/contributions/42' }
      let(:edit_resource_path) { '/projects/thirty-three/contributions/42/edit' }

      it_should_behave_like '#create'
    end
  end
end
