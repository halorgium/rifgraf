require "test/unit"
require "sinatra/test"
require File.dirname(__FILE__) + "/../main"

class AppTest < Test::Unit::TestCase
  include Sinatra::Test

  def create_graph
    post "/my_graph", :timestamp => Time.mktime(2008, 04, 07), :value => 10
    assert status == 201
  end

  def setup
    File.delete(File.dirname(__FILE__) + "/../rifgraf.db")
  rescue Errno::ENOENT
    true
  end

  def test_it_deletes_graph
    create_graph

    delete "/my_graph"
    assert ok?

    get "/my_graph"
    assert not_found?
  end

  def test_it_provides_html_representation_of_graph
    create_graph

    get "/my_graph", :env => {"HTTP_ACCEPT" => "text/html"}
    assert_equal "text/html", headers["Content-Type"]
    assert body =~ /flashcontent/

    get "/my_graph", :env => {"HTTP_ACCEPT" => "application/xml"}
    assert ok?
    assert body.start_with?("<settings>")
  end

  def test_it_provides_csv_representation_of_graph
    create_graph
    post "/my_graph", :timestamp => Time.mktime(2009, 10, 10), :value => 50

    get "/my_graph", :env => {"HTTP_ACCEPT" => "text/csv"}
    assert_equal body, "2009-10-10 00:00:00,0,50\n2008-04-07 00:00:00,0,10\n"
  end

  def test_it_returns_415_for_unsupported_representation_of_graph
    create_graph

    get "/my_graph", :env => {"HTTP_ACCEPT" => "text/css"}
    assert status == 415
  end
end
