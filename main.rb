require 'sinatra'
require 'sequel'

module Points
	def self.data
		@@data ||= make
	end

	def self.make
		db = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://rifgraf.db')
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

get "/:id" do
	throw :halt, [ 404, "No such graph" ] unless Points.data.filter(:graph => params[:id]).count > 0

  case env["HTTP_ACCEPT"]
  when "text/html"
    erb :graph, :locals => { :id => params[:id] }
  when "text/csv"
    erb :data, :locals => { :points => Points.data.filter(:graph => params[:id]).reverse_order(:timestamp) }
  when "application/xml"
    erb :amstock_settings, :locals => { :id => params[:id] }
  else
    status 415
  end
end

post "/:id" do
	Points.data << { :graph => params[:id], :timestamp => (params[:timestamp] || Time.now), :value => params[:value] }
	status 201
end

delete "/:id" do
	Points.data.filter(:graph => params[:id]).delete
end
