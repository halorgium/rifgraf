Bundler.require_env(:test)

$:.unshift 'lib'
require 'rifgraf'

spec = Gem::Specification.new do |s|
  s.name              = "rifgraf"
  s.version           = Rifgraf::VERSION
  s.author            = "Adam Wiggins"
  s.email             = "adam@heroku.com"
  s.homepage          = "http://github.com/halorgium/rifgraf"
  s.summary           = "Fire-and-forget data collection and graphing service"
  s.description       = s.summary
  s.files             = Dir["lib/**/*"]
  s.executables       = ['rifgraf']

  manifest = Bundler::Dsl.load_gemfile(File.dirname(__FILE__) + '/Gemfile')
  manifest.dependencies.each do |d|
    next unless d.only && d.only.include?('release')
    s.add_dependency(d.name, d.version)
  end
end

Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end
