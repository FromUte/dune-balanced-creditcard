module Neighborly::Balanced
  class Payment
    def initialize(customer, contribution, attrs = {})
      @customer, @contribution, @attrs = customer, contribution, attrs
    end

    def checkout!
      @debit = @customer.debit(amount:     @contribution.price_in_cents,
                               source_uri: @attrs.fetch(:use_card))
    end

    def successful?
      %w(pending succeeded).include? @debit.try(:status)
    end
  end
end
