module Neighborly::Balanced::Creditcard
  class NotificationsController < ApplicationController
    def create
      event = Neighborly::Balanced::Event.new(params)
      event.save

      status = event.valid? ? :ok : :bad_request
      render nothing: true, status: status
    end
  end
end
