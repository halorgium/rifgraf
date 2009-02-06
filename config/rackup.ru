require "rubygems"
require File.dirname(__FILE__) + "/../app"

RifGraf::App.set :env, ENV["APP_ENV"] || :production
RifGraf::App.disable :reload

run RifGraf::App
