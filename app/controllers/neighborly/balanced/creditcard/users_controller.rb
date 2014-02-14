module Neighborly::Balanced::Creditcard
  class UsersController < ActionController::Base
    def creditcard
      customer.add_card(card.uri)
    rescue Balanced::Conflict => e
      Rails.debug "Conflict when attaching credit card to customer."
      Rails.debug "Error: #{e.inspect}"

      head :bad_request
    else
      head :ok
    end
  end
end
