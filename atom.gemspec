# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'atom/version'

Gem::Specification.new do |spec|
  spec.name          = "atom"
  spec.version       = Atom::VERSION
  spec.authors       = ["d318503"]
  spec.email         = ["satou-y93@mail.dnp.co.jp"]

  spec.summary       = %q{DNP Standard ROR Architecture}
  spec.description   = %q{DNP Standard Ruby on Rails architecture designed to DREG Lean-Agile Framework.}
  spec.homepage      = "http://cf.cio.dnp.co.jp/"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://sdp.nbws.jp"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rails", "~> 4.2"
end
