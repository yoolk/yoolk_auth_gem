# -*- encoding: utf-8 -*-
require File.expand_path('../lib/yoolk_auth/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Yoolk Inc."]
  gem.email         = ["darren@yoolk.com"]
  gem.description   = %q{Authorizes an external app with Yoolk Core}
  gem.summary       = %q{Authorizes an external app with Yoolk Core}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "yoolk_auth"
  gem.require_paths = ["lib"]
  gem.version       = YoolkAuth::VERSION

  gem.add_dependency "rack"
  gem.add_development_dependency "rspec", "~> 2.11"
end
