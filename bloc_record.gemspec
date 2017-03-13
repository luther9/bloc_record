Gem::Specification.new { |s|
  s.name = 'bloc_record'
  s.version = '0.0.0'
  s.date = '2017-02-08'
  s.summary = 'BlocRecord ORM'
  s.description = 'An ActiveRecord-esque ORM adaptor'
  s.authors = ['Luther Thompson']
  s.email = 'lutheroto@gmail.com'
  s.files = Dir['lib/**/*.rb']
  s.require_paths = ['lib']
  s.homepage = 'http://rubygems.org/gems/bloc_record'
  s.license = 'CC 0'
  s.add_runtime_dependency('sqlite3', '~> 1.3')
  s.add_runtime_dependency('activesupport')
}
