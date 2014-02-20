module Neighborly::Balanced::Creditcard
  class PaymentsController < ActionController::Base
    def new
      prepare_new_view
    end

    def create
      credit_card = params[:payment].fetch(:use_card)
      unless customer.cards.any? { |c| c.id.eql? credit_card }
        customer.add_card(params[:payment].fetch(:use_card))
      end

      update_customer

      contribution = Contribution.find(params[:payment].fetch(:contribution_id))
      payment      = Neighborly::Balanced::Payment.new(contribution, resource_params)
      payment.checkout!

      if payment.successful?
        flash[:success] = t('success', scope: 'controllers.projects.contributions.pay')
        redirect_to main_app.project_contribution_path(
          project_id: contribution.project.id,
          id:         contribution.id
        )
      else
        prepare_new_view
        render 'new'
      end
    end

    private

    def resource_params
      params.require(:payment).
             permit(:contribution_id,
                    :use_card,
                    user: %i(name
                             address_street
                             address_city
                             address_state
                             address_zip_code
                             update_address))
    end

    def prepare_new_view
      @balanced_marketplace_id = ::Configuration.fetch(:balanced_marketplace_id)
      @cards                   = customer.cards
    end

    def update_customer
      customer.name     = resource_params[:user][:name]
      customer.address  = { line1:        resource_params[:user][:address_street],
                            city:         resource_params[:user][:address_city],
                            state:        resource_params[:user][:address_state],
                            postal_code:  resource_params[:user][:address_zip_code]
                          }
      customer.save
      current_user.update!(user_address_params[:payment][:user]) if params[:payment][:user][:update_address]
    end

    def user_address_params
      params.permit(payment: { user: [:address_street, :address_city, :address_state, :address_zip_code] })
    end

    def customer
      current_customer_uri = current_user.balanced_contributor.try(:uri)
      @customer ||= if current_customer_uri
                      ::Balanced::Customer.find(current_customer_uri)
                    else
                      initialize_customer
                    end
    end

    def initialize_customer
      customer = ::Balanced::Customer.new(meta:    { user_id: current_user.id },
                                          name:    current_user.display_name,
                                          email:   current_user.email,
                                          address: {
                                            line1:        current_user.address_street,
                                            city:         current_user.address_city,
                                            state:        current_user.address_state,
                                            postal_code:  current_user.address_zip_code
                                          })
      customer.save
      current_user.create_balanced_contributor(uri: customer.uri)

      customer
    end
  end
end
