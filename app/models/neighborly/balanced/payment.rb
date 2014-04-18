module Neighborly::Balanced
  class Payment
    def initialize(engine_name, customer, contribution, attrs = {})
      @engine_name  = engine_name
      @customer     = customer
      @contribution = contribution
      @attrs        = attrs
    end

    def checkout!
      @debit = @customer.debit(amount:     contribution_amount_in_cents,
                               source_uri: @attrs.fetch(:use_card),
                               appears_on_statement_as: ::Configuration[:balanced_appears_on_statement_as])
    rescue Balanced::PaymentRequired
      @contribution.cancel!
    else
      @contribution.confirm!
    ensure
      @contribution.update_attributes(
        payment_id:                       @debit.try(:id),
        payment_method:                   @engine_name,
        payment_service_fee:              fee_calculator.fees,
        payment_service_fee_paid_by_user: @attrs[:pay_fee]
      )
    end

    def contribution_amount_in_cents
      (fee_calculator.gross_amount * 100).round
    end

    def fee_calculator
      @fee_calculator and return @fee_calculator

      calculator_class = if ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include? @attrs[:pay_fee]
                           Creditcard::TransactionAdditionalFeeCalculator
                         else
                           Creditcard::TransactionInclusiveFeeCalculator
                         end

      @fee_calculator = calculator_class.new(@contribution.value)
    end

    def debit
      @debit.try(:sanitize)
    end

    def successful?
      %w(pending succeeded).include? @debit.try(:status)
    end
  end
end
