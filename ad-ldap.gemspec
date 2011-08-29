# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ad-ldap/version"

Gem::Specification.new do |s|
  s.name        = "ad-ldap"
  s.version     = AD::LDAP::VERSION
  s.authors     = ["Collin Redding"]
  s.homepage    = "http://github.com/teaminsight/ad-ldap"
  s.summary     = %q{A small wrapper to Net::LDAP to provide some extended functionality and utility.}
  s.description = %q{A small wrapper to Net::LDAP to provide some extended functionality and utility.}

  s.rubyforge_project = "ad-ldap"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "net-ldap", "~>0.2.2"

  s.add_development_dependency "assert",  "~>0.3.0"
  s.add_development_dependency "mocha",   "~>0.9.12"
end
