module Neighborly::Balanced::Creditcard
  class PaymentsController < ActionController::Base
    def new
      prepare_new_view
    end

    def create
      attach_card_to_customer
      update_customer

      contribution = Contribution.find(params[:payment].fetch(:contribution_id))
      payment      = Neighborly::Balanced::Payment.new(customer,
                                                       contribution,
                                                       resource_params)
      payment.checkout!

      if payment.successful?
        flash[:success] = t('success', scope: 'controllers.projects.contributions.pay')
        redirect_to main_app.project_contribution_path(
          contribution.project.permalink,
          contribution.id
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

    def user_params
      resource_params.permit(user: %i(
                               name
                               address_street
                               address_city
                               address_state
                               address_zip_code
                               update_address
                             ))[:user]
    end

    def prepare_new_view
      @balanced_marketplace_id = ::Configuration.fetch(:balanced_marketplace_id)
      @cards                   = customer.cards
    end

    def attach_card_to_customer
      credit_card = resource_params.fetch(:use_card)
      unless customer.cards.any? { |c| c.id.eql? credit_card }
        customer.add_card(resource_params.fetch(:use_card))
      end
    end

    def update_customer
      customer.name    = user_params[:name]
      customer.address = { line1:        user_params[:address_street],
                           city:         user_params[:address_city],
                           state:        user_params[:address_state],
                           postal_code:  user_params[:address_zip_code]
                         }
      customer.save

      if ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include? user_params.delete(:update_address)
        current_user.update!(user_params)
      end
    end

    def customer
      current_customer_uri = current_user.balanced_contributor.try(:uri)
      @customer          ||= if current_customer_uri
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
