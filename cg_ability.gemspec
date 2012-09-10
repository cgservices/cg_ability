Gem::Specification.new do |gem|
  gem.authors       = ['Luis Doubrava']
  gem.email         = ['luis@cg.nl']
  gem.description   = 'CG Ability Gem for engine authorization'
  gem.summary       = 'CG Ability Gem for engine authorization'
  gem.homepage      = ''

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'cg_ability'
  gem.require_paths = ['lib']
  gem.version       = "0.0.1pre"

  gem.add_dependency("cancan", ['>= 0'])
  gem.add_development_dependency('rake', ['>= 0'])
  gem.add_development_dependency('rspec', ['>= 0'])
  gem.add_development_dependency('yard')
end