review_path = ->(contribution) do
  Neighborly::Balanced::Creditcard::Engine.
    routes.url_helpers.new_payment_path(contribution_id: contribution)
end

total_with_fees = ->(value) do
  Neighborly::Balanced::Creditcard::Fee.new(value).total
end

begin
  PaymentEngines.register(name:           'balanced-creditcard',
                          locale:         'en',
                          total_with_fees: total_with_fees,
                          review_path:    review_path)
rescue Exception => e
  puts "Error while registering payment engine: #{e}"
end
