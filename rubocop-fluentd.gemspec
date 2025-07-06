# frozen_string_literal: true

require_relative "lib/rubocop/fluentd/version"

Gem::Specification.new do |spec|
  spec.name = "rubocop-fluentd"
  spec.version = RuboCop::Fluentd::VERSION
  spec.authors = ["Kentaro Hayashi"]
  spec.email = ["kenhys@gmail.com"]

  spec.summary = "RuboCop rules for Fluentd plugin"
  spec.description = "Collection rules for Fluentd plugin coding style"
  spec.homepage = "https://github.com/kenhys/rubocop-fluentd"
  spec.license = "Apache-2.0"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/kenhys/rubocop-fluentd"
  spec.metadata["changelog_uri"] = "https://github.com/kenhys/rubocop-fluentd/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html

  spec.metadata['default_lint_roller_plugin'] = 'RuboCop::Fluentd::Plugin'

  spec.add_dependency 'lint_roller', '~> 1.1'
  spec.add_dependency 'rubocop', '>= 1.72.2'
end

