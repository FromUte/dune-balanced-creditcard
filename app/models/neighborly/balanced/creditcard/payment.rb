module Neighborly::Balanced::Creditcard
  class Payment
    attr_reader :engine_name, :customer, :resource, :attrs

    def initialize(engine_name, customer, resource, attrs = {})
      @engine_name  = engine_name
      @customer     = customer
      @resource     = resource
      @attrs        = attrs
    end

    def checkout!
      card = Balanced::Card.fetch(attrs.fetch(:use_card))
      @debit = card.debit(amount: amount_in_cents,
                          appears_on_statement_as: ::Configuration[:balanced_appears_on_statement_as],
                          description: debit_description,
                          meta: meta)
    rescue Balanced::PaymentRequired
      resource.cancel!
    else
      resource.confirm!
    ensure
      resource.update_attributes(
        payment_id:                       @debit.try(:id),
        payment_method:                   engine_name,
        payment_service_fee:              fee_calculator.fees,
        payment_service_fee_paid_by_user: attrs[:pay_fee]
      )
      update_meta(@debit) if @debit
    end

    def amount_in_cents
      (fee_calculator.gross_amount * 100).round
    end

    def fee_calculator
      @fee_calculator and return @fee_calculator

      calculator_class = if ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include? attrs[:pay_fee]
                           TransactionAdditionalFeeCalculator
                         else
                           TransactionInclusiveFeeCalculator
                         end

      @fee_calculator = calculator_class.new(resource.value)
    end

    def debit
      @debit.try(:sanitize)
    end

    def successful?
      %w(pending succeeded).include? @debit.try(:status)
    end

    private

    def update_meta(debit)
      debit.meta = meta
      debit.save
    end

    def resource_name
      resource.class.model_name.singular
    end

    def debit_description
      I18n.t('description',
             project_name: resource.try(:project).try(:name),
             scope: "neighborly.balanced.creditcard.payments.debit.#{resource_name}")
    end

    def project_owner_customer
      @project_owner_customer ||= Neighborly::Balanced::Customer.new(
        resource.project.user, {}).fetch
    end

    def meta
      PayableResourceSerializer.new(resource).to_json
    end
  end
end
