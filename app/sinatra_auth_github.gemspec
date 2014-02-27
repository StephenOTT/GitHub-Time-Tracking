# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sinatra/auth/github/version"

Gem::Specification.new do |s|
  s.name        = "sinatra_auth_github"
  s.version     = Sinatra::Auth::Github::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Stephen Russett"]
  s.email       = ["stephenrussett@gmail.com"]
  s.homepage    = "http://github.com/StephenOTT/GitHub-Time-Tracking"
  s.summary     = ""
  s.license     = ""
  s.description = s.summary

  s.rubyforge_project = "sinatra_auth_github"

  s.add_dependency "sinatra",       "~>1.0"
  s.add_dependency "warden-github", "~>1.0"
  s.add_dependency "chronic_duration"
  s.add_dependency "mongo"
  s.add_dependency "bson_ext"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec",     "~>2.4.0"
  s.add_development_dependency "shotgun"
  s.add_development_dependency "randexp",   "~>0.1.5"
  s.add_development_dependency "rack-test", "~>0.5.3"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
