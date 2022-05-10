[![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner2-direct.svg)](https://stand-with-ukraine.pp.ua)

# Carddav

[![Build Status](https://travis-ci.org/timsly/carddav.svg?branch=master)](https://travis-ci.org/timsly/carddav)

Ruby implementation for the CardDAV protocol.

For now you can only get cards.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'carddav'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install carddav

## Usage

The gem was tested with two providers: `iCloud` and `gmx`.
To get contacts from these two providers do the following:

```ruby
service = Carddav.service(:gmx, 'email@gmx.net', 'password')
service.cards
```

or

```ruby
service = Carddav.service(:apple, 'email@icloud.com', 'password')
service.cards
```

Under the hood it uses `Carddav::Client`, which uses the standard approach of getting data
from CardDAV servers.

```ruby
client = Carddav::Client.new('http://my-carddav-server.org', 'email@mail.net', 'password')
client.cards
```

## Discovery process

`Carddav::Client` discovers urls step by step and then, as the last step, gets data from `addressbook_url`
and then parses vcards from the response.

Here are all steps:

* getting `current_user_principal` url
* getting `addressbook_home_set` url
* getting `addressbook` url
* getting cards

When one of the urls is static it can be passed to the client directly.
This way some steps in the discovery process will be bypassed

```ruby
client = Carddav::Client.new('http://my-carddav-server.org', 'email@mail.net', 'password')
client.addressbook_url = '/my-addressbook-url'
client.cards # http://my-carddav-server.org/my-addressbook-url will be used and cards will be fetched from it.
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/timsly/carddav.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
