# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "geonames/version"

Gem::Specification.new do |s|
  s.name     = "ruby-geonames"
  s.version  = Geonames::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors  = ["Adam Wisniewski"]
  s.email    = ["adamw@tbcn.ca"]
  s.homepage = "http://github.com/elecnix/ruby-geonames"
  s.summary  = %q{Ruby library for Geonames Web Services (http://www.geonames.org/export/)}
  s.licenses = ["Apache 2.0"]

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- spec/**/*_spec.rb`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = ["README.markdown"]

  s.add_development_dependency "bundler"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
end
