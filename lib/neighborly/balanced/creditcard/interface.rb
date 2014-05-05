module Neighborly::Balanced::Creditcard
  class Interface

    def name
      'balanced-creditcard'
    end

    def payment_path(resource)
      key = "#{ActiveModel::Naming.param_key(resource)}_id"
      Neighborly::Balanced::Creditcard::Engine.
        routes.url_helpers.new_payment_path(key => resource)
    end

    def account_path
      false
    end

    def fee_calculator(value)
      TransactionAdditionalFeeCalculator.new(value)
    end

    def payout_class
      Neighborly::Balanced::Payout
    end

  end
end
