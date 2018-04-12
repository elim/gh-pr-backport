
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gh_pr_backport/version"

Gem::Specification.new do |spec|
  spec.name          = "gh-pr-backport"
  spec.version       = GhPrBackport::VERSION
  spec.authors       = ["Takeru Naito"]
  spec.email         = ["takeru.naito@gmail.com"]

  spec.summary       = %q{Create a backport Pull Request.}
  spec.description   = %q{Create a backport PR from existing PR to a specific branch.}
  spec.homepage      = "https://github.com/elim/gh-pr-backport"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # it a nonexistent host.
    spec.metadata["allowed_push_host"] = "https://gems.hermes-wings.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_dependency "hashie", "~> 3.5.7"
  spec.add_dependency "octokit", "~> 4.8.0"
end
