require "sinatra"
require "sequel"

module Points
	def self.data
		@@data ||= make
	end

	def self.make
		db = Sequel.connect(ENV["DATABASE_URL"] || "sqlite://rifgraf.db")
		make_table(db)
		db[:points]
	end

	def self.make_table(db)
		db.create_table :points do
			varchar :graph, :size => 32
			varchar :value, :size => 32
			timestamp :timestamp
		end
	rescue Sequel::DatabaseError
		# assume table already exists
	end
end

helpers do
  def graph
    @graph ||= Points.data.filter(:graph => params[:graph])
  end

  def to_csv(points)
    points.inject("") { |s, p|
      s << p[:timestamp].strftime("%Y-%m-%d %H:%M:%S").to_s +
        ",0," + p[:value] + "\n"
    }
  end
end

get "/:graph" do
	throw :halt, [ 404, "No such graph" ] unless graph.count > 0

  case env["HTTP_ACCEPT"]
  when "text/html"
    erb :graph, :locals => { :id => params[:graph] }
  when "text/csv"
    to_csv(graph.reverse_order(:timestamp))
  when "application/xml"
    erb :amstock_settings, :locals => { :id => params[:graph] }
  else
    status 415
  end
end

post "/:graph" do
	Points.data << { :graph => params[:graph],
    :timestamp  => (params[:timestamp] || Time.now),
    :value      => params[:value] }
	status 201
end

delete "/:graph" do
  graph.delete
end
