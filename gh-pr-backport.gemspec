
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gh_pr_backport/version'

Gem::Specification.new do |spec|
  spec.name          = 'gh-pr-backport'
  spec.version       = GhPrBackport::VERSION
  spec.authors       = ['Takeru Naito']
  spec.email         = ['takeru.naito@gmail.com']

  spec.summary       = 'Create a backport Pull Request.'
  spec.description   = 'Create a backport PR from existing PR to a specific branch.'
  spec.homepage      = 'https://github.com/elim/gh-pr-backport'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop-codetakt', '~> 0.8.2'
  spec.add_runtime_dependency 'hashie', '~> 3.5', '>= 3.5.7'
  spec.add_runtime_dependency 'octokit', '~> 4.8', '>= 4.8.0'
end
