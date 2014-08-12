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
      meta = {
              payment_service_fee: fee_calculator.fees,
              payment_service_fee_paid_by_user: attrs[:pay_fee],
              project: {
                id:        resource.project.id,
                name:      resource.project.name,
                permalink: resource.project.permalink,
                user:      resource.project.user.id
              },
              user: {
                id:        resource.user.id,
                name:      resource.user.display_name,
                email:     resource.user.email,
                address:   { line1:        resource.user.address_street,
                             city:         resource.user.address_city,
                             state:        resource.user.address_state,
                             postal_code:  resource.user.address_zip_code
                }
              }
            }
      if resource.respond_to? :reward
        meta.merge!({
          reward: {
                id:          resource.reward.try(:id),
                title:       resource.reward.try(:title),
                description: resource.reward.try(:description)
              }
          })
      end

      meta
    end
  end
end
