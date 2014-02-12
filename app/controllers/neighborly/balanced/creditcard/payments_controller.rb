module Neighborly::Balanced::Creditcard
  class PaymentsController < ActionController::Base
    def new
      unless current_user.balanced_contributor
        customer = Balanced::Customer.new(meta:  { user_id: current_user.id },
                                          name:  current_user.name,
                                          email: current_user.email)
        customer.save
        current_user.create_balanced_contributor(uri: customer.uri)
      end
    end
  end
end
