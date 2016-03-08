# Welcome to Atom

Atom is an extension package for Ruby on Rails web-application framework in order to accelerate an innovation activity in DNP C&I from a development aspect.

All we, developers, have to do is ... Accomplish the Owners Mind.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'atom', git: 'https://sdp.nbws.jp/dreg-gitlab/SPF-DREGroup/atom_rails.git'
```

And then execute:

    $ bundle install


## Usage

    $ bin/rails g atom:install

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).