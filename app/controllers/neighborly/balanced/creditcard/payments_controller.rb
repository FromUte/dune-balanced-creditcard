module Neighborly::Balanced::Creditcard
  class PaymentsController < ActionController::Base
    def new
      if current_user.balanced_contributor
        @customer = Balanced::Customer.find(current_user.balanced_contributor.uri)
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
  end
end
