review_path = Neighborly::Balanced::Creditcard::Engine.
                routes.url_helpers.new_payment_path(contribution)
begin
  PaymentEngines.register(name:        'balanced-creditcard',
                          locale:      'en',
                          review_path: ->(contribution) { review_path })
rescue Exception => e
  puts "Error while registering payment engine: #{e}"
end
