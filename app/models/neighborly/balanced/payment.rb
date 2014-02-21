module Neighborly::Balanced
  class Payment
    def initialize(customer, contribution, attrs = {})
      @customer, @contribution, @attrs = customer, contribution, attrs
    end

    def checkout!
      @debit = @customer.debit(amount: @contribution.price_in_cents,
                               source: @attrs.fetch(:use_card))
      @contribution.update_attributes(payment_id:     @debit.id,
                                      payment_method: :balanced,
                                      payment_choice: :creditcard)
    end

    def debit
      @debit.try(:sanitize)
    end

    def successful?
      %w(pending succeeded).include? @debit.try(:status)
    end
  end
end
