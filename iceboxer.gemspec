$:.push File.expand_path("../lib", __FILE__)

require 'iceboxer/version'

Gem::Specification.new do |spec|
  spec.name          = "iceboxer"
  spec.version       = Iceboxer::VERSION
  spec.authors       = ["Tom Burns"]
  spec.summary       = "task to daily find & close open stale github issues"

  spec.files         = Dir["{lib}/**/*", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency 'rake'
  spec.add_dependency 'octokit'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'httparty'
  spec.add_dependency 'dotenv'
end
