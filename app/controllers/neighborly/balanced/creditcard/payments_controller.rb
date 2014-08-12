module Neighborly::Balanced::Creditcard
  class PaymentsController < ActionController::Base
    before_filter :authenticate_user!

    def new
      @cards = customer.cards
    end

    def create
      attach_card_to_customer
      update_customer

      payment = Payment.new('balanced-creditcard',
                             customer,
                             resource,
                             resource_params)
      payment.checkout!
      redirect_to(*checkout_response_params(resource, payment.successful?))
    end

    private
    def resource
      @resource ||= if params[:payment][:match_id].present?
                      Match.find(params[:payment].fetch(:match_id))
                    else
                      Contribution.find(params[:payment].fetch(:contribution_id))
                    end
    end

    def resource_name
      resource.class.model_name.singular.to_sym
    end

    def checkout_response_params(resource, success)
      status = success ? :succeeded : :failed
      route_params = [resource.project.permalink, resource.id]

      {
        contribution: {
          succeeded: [
            main_app.project_contribution_path(*route_params)
          ],
          failed: [
            main_app.edit_project_contribution_path(*route_params),
            alert: t('.errors.default')
          ]
        },
        match: {
          succeeded: [
            main_app.project_match_path(*route_params)
          ],
          failed: [
            main_app.edit_project_match_path(*route_params),
            alert: t('.errors.default')
          ]
        }
      }.fetch(resource_name).fetch(status)
    end

    def resource_params
      params.require(:payment).
             permit(:contribution_id,
                    :match_id,
                    :use_card,
                    :pay_fee,
                    user: {})
    end

    def attach_card_to_customer
      card = Balanced::Card.fetch(resource_params.fetch(:use_card))
      unless customer.cards.to_a.any? { |c| c.id.eql? card.id }
        card.associate_to_customer(customer)
      end
    end

    def customer
      @customer ||= Neighborly::Balanced::Customer.new(current_user, params).fetch
    end

    def update_customer
      Neighborly::Balanced::Customer.new(current_user, params).update!
    end
  end
end
