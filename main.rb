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
  def format
    @format ||= params["format"] || env["HTTP_ACCEPT"].to_s.split("/").last
  end

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

get "/:graph.?:format?" do
  halt 404 unless graph.count > 0

  case format
  when "html"
    content_type :html
    erb :graph, :locals => { :id => params[:graph] }
  when "csv"
    content_type :csv
    to_csv(graph.reverse_order(:timestamp))
  when "xml"
    content_type :xml
    erb :settings, :locals => { :id => params[:graph] }
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

__END__

@@ graph
<!DOCTYPE html>
<html>
<head>
  <title>rifgraf | <%= id %></title>
</head>
<body>
<script type="text/javascript" src="/swfobject.js"></script>
<p id="flashcontent"><strong>The graph isn't loading.</strong></p>
<script type="text/javascript">
// <![CDATA[
var so = new SWFObject("/amstock.swf", "amline", "100%", "100%", "8", "#FFFFFF");
so.addVariable("settings_file", escape("/graphs/<%= id %>/amstock_settings.xml"));
so.addVariable("preloader_color", "#999999");
so.write("flashcontent");
// ]]>
</script>
</body>
</html>

@@ settings
<settings>
  <margins>0</margins>
  <equal_spacing>false</equal_spacing>
  <redraw>true</redraw>
  <number_format>
    <letters>
      <letter number="1000">K</letter>
      <letter number="1000000">M</letter>
      <letter number="1000000000">B</letter>
      </letters>
  </number_format>
  <data_sets>
    <data_set>
      <title><%= id %></title>
      <short><%= id %></short>
      <color>004090</color>
      <file_name>/graphs/<%= id %>/data.csv</file_name>
      <csv>
        <reverse>true</reverse>
        <separator>,</separator>
        <date_format>YYYY-MM-DD hh:mm:ss</date_format>
        <decimal_separator>.</decimal_separator>
        <columns>
          <column>date</column>
          <column>volume</column>
          <column>close</column>
        </columns>
      </csv>
    </data_set>
  </data_sets>

  <charts>
    <chart>
      <height>60</height>
      <title>Value</title>
      <border_color>#CCCCCC</border_color>
      <border_alpha>100</border_alpha>

      <values>
        <x>
          <bg_color>EEEEEE</bg_color>
        </x>
      </values>
      <legend>
        <show_date>true</show_date>
      </legend>

      <column_width>100</column_width>

      <graphs>
        <graph>
          <data_sources>
            <close>close</close>
          </data_sources>

          <bullet>round_outline</bullet>

          <legend>
            <date key="false" title="false"><![CDATA[{close}]]></date>
            <period key="false" title="false"><![CDATA[open:<b>{open}</b> low:<b>{low}</b> high:<b>{high}</b> close:<b>{close}</b>]]></period>
          </legend>
        </graph>
      </graphs>
    </chart>

  </charts>

  <data_set_selector>
    <enabled>false</enabled>
  </data_set_selector>

  <period_selector>
    <periods>
      <period type="HH" count="1">1H</period>
      <period type="DD" count="1">1D</period>
      <period type="DD" count="10">10D</period>
      <period type="MM" count="1">1M</period>
      <period type="MM" count="3">3M</period>
      <period type="YTD" count="0">YTD</period>
      <period selected="true" type="MAX">MAX</period>
    </periods>

    <periods_title>Zoom:</periods_title>
    <custom_period_title>Custom period:</custom_period_title>
  </period_selector>

  <header>
    <enabled>false</enabled>
  </header>

  <scroller>
    <graph_data_source>close</graph_data_source>
    <resize_button_style>dragger</resize_button_style>
    <playback>
      <enabled>true</enabled>
      <speed>3</speed>
    </playback>
  </scroller>
</settings>
