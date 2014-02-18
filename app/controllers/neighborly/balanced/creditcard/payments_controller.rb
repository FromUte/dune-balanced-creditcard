module Neighborly::Balanced::Creditcard
  class PaymentsController < ActionController::Base
    def new
      if current_user.balanced_contributor
        @customer = resource
      else
        @customer = Balanced::Customer.new(meta:   { user_id: current_user.id },
                                          name:    current_user.display_name,
                                          email:   current_user.email,
                                          address: {
                                                    line1:        current_user.address_street,
                                                    city:         current_user.address_city,
                                                    state:        current_user.address_state,
                                                    postal_code:  current_user.address_zip_code
                                                   })
        @customer.save
        current_user.create_balanced_contributor(uri: @customer.uri)
      end
      @cards = @customer.cards
    end

    def create
      # Attach card
      customer = Balanced::Customer.find(params[:payment].fetch(:customer_uri))
      customer.add_card(params[:payment].fetch(:use_card))
    end

    private
    def update_customer
      customer          = resource
      customer.name     = params[:payment][:user][:name]
      customer.address  = { line1:        params[:payment][:user][:address_street],
                            city:         params[:payment][:user][:address_city],
                            state:        params[:payment][:user][:address_state],
                            postal_code:  params[:payment][:user][:address_zip_code]
                          }
      customer.save
      current_user.update!(user_address_params[:payment][:user]) if params[:payment][:user][:update_address]
    end

    def user_address_params
      params.permit(payment: { user: [:address_street, :address_city, :address_state, :address_zip_code] })
    end

    def resource
      @customer ||= Balanced::Customer.find(current_user.balanced_contributor.uri)
    end
  end
end
