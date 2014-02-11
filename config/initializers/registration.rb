review_path = ->(contribution) do
  Neighborly::Balanced::Creditcard::Engine.
    routes.url_helpers.new_payment_path(contribution_id: contribution)
end

begin
  PaymentEngines.register(name:        'balanced-creditcard',
                          locale:      'en',
                          review_path: review_path)
rescue Exception => e
  puts "Error while registering payment engine: #{e}"
end
