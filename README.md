# OmniAuth Fortnox OAuth2 Strategy

Strategy to authenticate with Fortnox via OAuth2 in OmniAuth.

You will need to create your app in order to get `Client-ID` and `Client-Secret`, read more here: [Fortnox](https://developer.fortnox.se/get-started-details/#create-your-app)

For more details, read the Fortnox docs: [Fortnox Developer](https://developer.fortnox.se/general/authentication/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-fortnox-oauth2'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install omniauth-fortnox-oauth2

## Usage

Here's an example for adding the middleware to a Rails app in config/initializers/omniauth.rb:

```ruby
  provider :fortnox_oauth2,
            'client-id',
            'client-secret',
            scope: 'companyinformation',
```

Can also be set up with dynamic configuration:

```ruby
  provider :fortnox_oauth2,
           setup: (lambda do |env|
                     # The following can be set dynamically from params, session, or ENV

                     env['omniauth.strategy'].options[:client_id] = 'client-id'
                     env['omniauth.strategy'].options[:client_secret] = 'client-secret'
                     env['omniauth.strategy'].options[:scope] = 'companyinformation'
                   end)
```

Service account in Fortnox can be configured with the optional parameter `account_type`.
```ruby
  account_type: 'service'
```

You can now access the OmniAuth Fortnox OAuth2 URL: /auth/fortnox_oauth2
Later a controller can be set up to handle the response after authentication, for example:

```ruby
get '/auth/fortnox_oauth2/callback', to: 'auth/fortnox_oauth2#callback'
```

## Configuration

You can configure several options, which you pass in to the provider method via a hash:

* `scope`: A comma-separated list of permissions you want to request from the user. See the [Fortnox](https://developer.fortnox.se/general/scopes/) for a full list of available permissions. Caveats:
  * Note that you app will need the same scopes! The scope `companyinformation` is used by default. By defining your own `scope`, you override these defaults.

* `callback_url`: Override the callback_url used by the gem.

You can also configure the `client_options` by passing in any of the following settings in a `client_options` hash, inside options.

* `site`: Override the site used by the gem, default: `https://apps.fortnox.se`.

* `token_url`: Override the token_url used by the gem, default: `/oauth-v1/token`.

* `authorize_url`: Override the authorize_url used by the gem, default `/oauth-v1/auth`.

* `auth_scheme`: Override the auth_scheme used by the gem, default `:basic_auth`.

* `token_method`: Override the token_method used by the gem, default `:post`.

## Note
Currently the only way to support multiple redirect uri's in Fortnox is to add them sperated using ` ` (space). This will work for the initial request to get the authorization code.
When trading the code for a token the `redirect_uri` will be matched using the string used in Fortnox developer portal. This is beeing changed but for now the workaround is to pass that string.
This can here be passed as an option `fortnox_redirect_uri`, it can contain one or multiple uri's.
This will need to exactly match the string in Fortnox.

For example:
```ruby
env['omniauth.strategy'].options[:fortnox_redirect_uri] = 'https://test.test/callback https://second-test.test/callback'
```

## Auth Hash

Here's an example of an authentication hash available in the callback by accessing `request.env['omniauth.auth']`:

```ruby
{
  "provider" => "fortnox_oauth2",
  "uid" => "556469-6291",
  "info" => {
    "address" => "Bollvägen",
    "city" => "Växjö",
    "country_code" => "SE",
    "database_number" => "654896",
    "company_name" => "Fortnox",
    "organization_number" => "556469-6291",
    "zip_code" => "35246"
  },
  "credentials" => {
    "token" => "TOKEN",
    "refresh_token" => "REFRESH_TOKEN",
    "expires_at" => 1496120719,
    "expires" => true
  },
  "extra" => {
    "raw_info" => {
      "Address" => "Bollvägen",
      "City" => "Växjö",
      "CountryCode" => "SE",
      "DatabaseNumber" => "654896",
      "CompanyName" => "Fortnox",
      "OrganizationNumber" => "556469-6291",
      "VisitAddress" => "",
      "VisitCity" => "",
      "VisitZipCode" => "",
      "ZipCode" => "35246",
    }
  }
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/standout/omniauth-fortnox-oauth2.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
