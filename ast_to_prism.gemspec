# frozen_string_literal: true

require_relative "lib/ast_to_prism/version.rb"

Gem::Specification.new do |spec|
  spec.name          = "ast_to_prism"
  spec.version       = AstToPrism::VERSION
  spec.authors       = ["Yuichiro Kaneko"]
  spec.email         = ["spiketeika@gmail.com"]

  spec.summary       = ""
  spec.description   = ""
  spec.homepage      = "https://github.com/yui-knk/ast_to_prism"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end

  spec.metadata["homepage_uri"]      = spec.homepage
  spec.metadata["source_code_uri"]   = spec.homepage
  spec.metadata["documentation_uri"] = spec.homepage
  spec.metadata["changelog_uri"]     = "#{spec.homepage}/releases"
  spec.metadata["bug_tracker_uri"]   = "#{spec.homepage}/issues"

  spec.add_runtime_dependency "prism", "0.30.0"

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end