module Neighborly::Balanced
  class Event
    TYPES = %w(debit.created debit.succeeded)

    def initialize(request_params)
      @request_params = request_params
    end

    def save
      PaymentEngines.create_payment_notification(
        contribution_id: contribution.id,
        extra_data:      @request_params[:registration].to_json
      )
    end

    def valid?
      valid_type? && values_matches?
    end

    def contribution
      Contribution.find_by(payment_id: @request_params.fetch(:entity).fetch(:id))
    end

    protected

    def valid_type?
      TYPES.include? @request_params.fetch(:type)
    end

    def values_matches?
      contribution.try(:price_in_cents).eql?(payment_amount)
    end

    def payment_amount
      @request_params.fetch(:entity).fetch(:amount).to_i
    end
  end
end
