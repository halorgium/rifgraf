module Rifgraf
  class App < Sinatra::Base
    set :views,   File.dirname(__FILE__) + "/views"

    get "/:graph" do
      halt(404, "No such graph: #{graph_name.inspect}") unless graph.count > 0

      case format
      when "csv"
        content_type :csv
        to_csv(graph.reverse_order(:timestamp))
      when "json"
        content_type :json
        data = graph.reverse_order(:timestamp).map do |point|
          timestamp = point[:timestamp].to_i * 1000
          value     = point[:value]
          [timestamp, value]
        end
        {:label => graph_name, :data => data}.to_json
      else
        content_type :html
        erb :graph, :locals => { :id => params[:graph] }
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
        @format ||= params["format"] || env["HTTP_ACCEPT"].split(",").first.split("/").last
      end

      def graph_name
        params[:graph]
      end

      def graph
        @graph ||= Points.data.filter(:graph => graph_name)
      end

      def to_csv(points)
        points.inject([]) { |csv, p|
          csv << p[:timestamp].strftime("%Y-%m-%d %H:%M:%S") + ",0,#{p[:value]}"
        }.join("\n")
      end
  end
end
