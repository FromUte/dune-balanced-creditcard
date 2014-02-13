options = Rails.env.development? ? { logging_level: 'INFO' } : {}
Balanced.configure(Configuration.fetch(:balanced_api_key_secret), options)
