require 'rack'
require 'json'
require 'sinatra/base'
require 'sequel'
require 'rack/client'

require 'rifgraf/cli'
require 'rifgraf/points'
require 'rifgraf/app'

module Rifgraf
  Rackup = Rack::Client.new do
    use Rack::Static, :urls => ["/css", "/img", "/js"], :root => File.dirname(__FILE__) + "/rifgraf/public"
    run App
  end
end
