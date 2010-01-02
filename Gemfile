clear_sources
source "http://gemcutter.org"

only :release do
  gem "sequel"
  gem "sinatra"
  gem "sqlite3-ruby"
  gem "rack-client"
  gem "json"
end

only :test do
  gem "rake",     :require_as => %w( rake rake/gempackagetask )
  gem "bundler",  :require_as => nil
end

bin_path "gbin"
disable_system_gems
