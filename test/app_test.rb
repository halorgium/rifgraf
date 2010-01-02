require "test/unit"
require File.dirname(__FILE__) + "/../vendor/gems/environment"
Bundler.require_env(:test)

$:.unshift File.dirname(__FILE__) + "/../lib"
require "rifgraf"

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def create_graph
    post "/my_graph", :timestamp => Time.mktime(2008, 04, 07), :value => 10
    assert last_response.status == 201
  end

  def app
    @app ||= Rifgraf::App
  end

  def setup
    File.delete(File.dirname(__FILE__) + "/../rifgraf.db")
  rescue Errno::ENOENT
    true
  end

  alias_method :teardown, :setup

  def test_it_provides_a_little_explanation
    get "/"
    assert last_response.ok?
    assert last_response.body =~ /This is/
  end

  def test_it_deletes_graph
    create_graph

    delete "/my_graph"
    assert last_response.ok?

    get "/my_graph"
    assert last_response.body == 'No such graph: "my_graph"'
    assert last_response.not_found?
  end

  def test_it_provides_html_representation_of_graph
    create_graph

    get "/my_graph", {}, "HTTP_ACCEPT" => "text/html"
    assert last_response.ok?
    assert last_response.headers["Content-Type"] == "text/html"
    assert_match /title.*my_graph/, last_response.body
  end

  def test_it_provides_csv_representation_of_graph
    create_graph
    post "/my_graph", :timestamp => Time.mktime(2009, 10, 10), :value => 50

    get "/my_graph", {}, "HTTP_ACCEPT" => "text/csv"
    assert last_response.ok?
    assert last_response.headers["Content-Type"] == "text/csv"
    assert_equal last_response.body, "2009-10-10 00:00:00,0,50\n2008-04-07 00:00:00,0,10"
  end
end
