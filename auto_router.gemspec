Gem::Specification.new do |spec|
  spec.name        = 'auto_router'
  spec.version     = '0.1.X'
  spec.date        = '2017-10-27'
  spec.summary     = 'Java Spring / C# WebMVC like Action mappings for Rails 4'
  spec.description = 'A different approach on rails routing.'
  spec.authors     = ['Oliver Kuster']
  spec.email       = 'olivervbk@gmail.com'
  spec.files       = Dir['{bin,lib,man,test,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")
  spec.homepage    = 'https://github.com/olivervbk/rails-auto-router'
  spec.license     = 'MIT'

  spec.add_development_dependency 'rake', '12.0.0'
  spec.add_development_dependency 'rspec', '3.5.0'
  spec.add_development_dependency 'rspec-collection_matchers', '1.1.3'
end
