require "test/unit"
require "sinatra/test"
require File.dirname(__FILE__) + "/../main"

class AppTest < Test::Unit::TestCase
  include Sinatra::Test

  def create_graph
    post "/graphs/my_graph", :timestamp => Time.mktime(2008, 04, 07), :value => 10
    assert status == 201
  end

  def setup
    File.delete(File.dirname(__FILE__) + "/../rifgraf.db")
  rescue Errno::ENOENT
    true
  end

  def test_it_works
    get "/"
    assert @response.body.include?("Rifgraf is a fire-and-forget")
  end

  def test_it_stores_graph
    create_graph

    get "/graphs/my_graph"
    assert ok?
  end

  def test_it_deletes_graph
    create_graph

    delete "/graphs/my_graph"
    assert ok?

    get "/graphs/my_graph"
    assert not_found?
  end

  def test_it_provides_html_representation_of_graph
    create_graph

    get "/graphs/my_graph"
    assert_equal "text/html", headers["Content-Type"]
    assert body =~ /flashcontent/

    get "/graphs/my_graph/amstock_settings.xml"
    assert ok?
    assert body.start_with?("<settings>")
  end

  def test_it_provides_csv_representation_of_graph
    create_graph

    get "/graphs/my_graph/data.csv"
    assert body == "2008-04-07 00:00:00,0,10\n\n" # TODO: no \n
  end
end
