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
      complete_request_with(resource, payment.successful?)
    end

    private
    def resource
      @resource ||= if params[:payment][:projects_match_id].present?
                      Projects::Match.find(params[:payment].fetch(:projects_match_id))
                    else
                      Contribution.find(params[:payment].fetch(:contribution_id))
                    end
    end

    def complete_request_with(resource, success)
      status = success ? :success : :fail
      route_params = [resource.project.permalink, resource.id]

      {
        contribution: {
          success: -> do
            redirect_to main_app.project_contribution_path(*route_params)
          end,

          fail: -> do
            flash.alert = t('.errors.default')
            redirect_to main_app.edit_project_contribution_path(*route_params)
          end
        },
        projects_match: {
          success: -> do
            redirect_to main_app.project_match_path(*route_params)
          end,

          fail: -> do
            flash.alert = t('.errors.default')
            redirect_to main_app.edit_project_match_path(*route_params)
          end
        }
      }.fetch(resource.class.model_name.singular.to_sym).fetch(status).call
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
