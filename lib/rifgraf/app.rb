module Rifgraf
  class App < Sinatra::Base
    set :views,   File.dirname(__FILE__) + "/views"

    get "/:graphs" do
      halt(404, "No graphs specified") unless graphs.count > 0

      case format
      when "json"
        content_type :json
        data = []
        graphs.each do |name,points|
          d = points.reverse_order(:timestamp).map do |point|
            timestamp = point[:timestamp].to_i * 1000
            value     = point[:value]
            [timestamp, value]
          end
          data << {:label => name, :data => d}
        end
        {:graphs => data}.to_json
      else
        content_type :html
        erb :graph
      end
    end

    post "/:graph" do
      Points.data << { :graph     => params["graph"],
                       :timestamp => params["timestamp"] || Time.now,
                       :value     => params["value"] }
      status 201
    end

    delete "/:graph" do
      graph.delete
      "OK"
    end

    get "/" do
      %q{This is <a href="http://github.com/sr/rifgraf">sr/rifgraf</a>.}
    end

    protected
      def format
        @format ||= params["format"] || env["HTTP_ACCEPT"].split(",").first.split("/").last || "html"
      end

      def graph_name
        params[:graph]
      end

      def graph
        @graph ||= graph_for(graph_name)
      end

      def graph_for(name)
        Points.data.filter(:graph => name)
      end

      def graph_names
        params[:graphs].split(",")
      end

      def graphs
        @graphs ||= load_graphs
      end

      def load_graphs
        g = {}
        graph_names.map do |name|
          g[name] = graph_for(name)
        end
        g
      end
  end
end
