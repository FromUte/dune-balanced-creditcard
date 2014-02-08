# Neighborly::Balanced::Creditcard


## UNDER ACTIVE DEVELOPMENT

This won't work for now. Feel free to follow the project and contribute, but it's not ready for production.

## What

This is an integration between [Balanced](https://www.balancedpayments.com/) and [Neighborly](https://github.com/luminopolis/neighborly), a crowdfunding platform.

## How

Include this gem as dependency of your project, adding the following line in your `Gemfile`.

```ruby
# Gemfile
gem 'neighborly-balanced-creditcard'
```

Neighborly::Balanced::Creditcard is a Rails Engine, integrating with your (Neighborly) Rails application with very little of effort. To turn the engine on, mount it in an appropriate route:

```ruby
# config/routes.rb
mount Neighborly::Balanced::Creditcard::Engine => '/', as: 'neighborly_balanced_creditcard'
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Running specs

We prize for our test suite and coverage, so it would be great if you could run the specs to ensure that your patch is not breaking the existing codebase.

When running specs for the first time, you need to initialize a database for the Neighborly application downloaded to `test/dummy`.

```console
$ cd test/dummy
$ RAILS_ENV=test rake db:drop db:create db:migrate
$ RAILS_ENV=test rake db:seed:development
$ cd ..
```

Yes, we should automate this process.

**to be continued**
