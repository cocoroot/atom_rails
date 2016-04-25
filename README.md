# Welcome to Atom

Atom is an extension package for Ruby on Rails web-application framework in order to accelerate an innovation activity in DNP C&I from a development aspect.

All we, developers, have to do is ... Accomplish the Owners Mind.


## Usage - for Basic (API based) web application

clone this repository into your <workspace>

    $ cd <workspace>
    $ git clone https://sdp.nbws.jp/dreg-gitlab/SPF-DREGroup/atom_rails.git

then, create new rails application

    $ rails new <project_name> -d postgresql -m <path_to_template_file> -T -B

have &lt;path_to_template_file&gt; indicate to cloned local file as

    <workspace>/atom_rails/lib/atom/rails_template.rb

sample:

    $ rails new sample_app -d postgresql -m <path_to_atom_rails>/lib/atom/rails_template.rb -T -B

## Usage - for DBaaS authentication

after installing atom along the step above, execute command below in your rails project directory

    $ bin/rails g atom:dbaas 


## Usage - for Frontend(HTML/JS) framework

    $ bin/rails g atom:frontend

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).