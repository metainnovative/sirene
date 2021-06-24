# frozen_string_literal: true

require_relative 'lib/sirene/version'

Gem::Specification.new do |spec|
  spec.name          = 'sirene'
  spec.version       = Sirene::VERSION
  spec.authors       = ['Jonathan PHILIPPE']
  spec.email         = ['jonathan.philippe@metainnovative.net']

  spec.summary       = %q{}
  spec.description   = %q{}
  spec.homepage      = 'https://github.com/metainnovative/sirene'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/metainnovative/sirene'
    spec.metadata['changelog_uri'] = 'https://github.com/metainnovative/sirene/CHANGELOG.md'
  end

  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 13.0'

  spec.add_dependency 'activesupport', '>= 5.0'
  spec.add_dependency 'rubyzip', '~> 2.0'
  spec.add_dependency 'smarter_csv', '~> 1.2', '>= 1.2.8'
end
