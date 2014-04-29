module Neighborly::Balanced::Creditcard
  class PaymentsController < ActionController::Base
    before_filter :authenticate_user!

    def new
      @balanced_marketplace_id = ::Configuration.fetch(:balanced_marketplace_id)
      @cards                   = customer.cards
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
      @resource ||= if params[:payment][:projects_match_id].present?
                      Projects::Match.find(params[:payment].fetch(:projects_match_id))
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
        projects_match: {
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
                    :projects_match_id,
                    :use_card,
                    :pay_fee,
                    user: {})
    end

    def attach_card_to_customer
      credit_card = resource_params.fetch(:use_card)
      unless customer.cards.any? { |c| c.id.eql? credit_card }
        customer.add_card(resource_params.fetch(:use_card))
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
