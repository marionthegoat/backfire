$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require 'backfire/version.rb'

# Metadata
Gem::Specification.new do |s|
  s.name        = "backfire"
  s.version     = Backfire::VERSION
  s.authors     = ["Lonnie Knechtel"]
  s.email       = ["lonnie@oneinchrr.com"]
  s.homepage    = "https://github.com/marionthegoat"
  s.summary     = "Simple back-chaining rule engine."
  s.description = "Back-chaining rule engine with support for handling abstract lists of facts"

# Manifest
  s.files = Dir["lib}/**/*"] + ["LICENSE", "Rakefile", "README"]
  s.test_files = Dir["test/**/*"]

# Dependencies
  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-reporters"

end