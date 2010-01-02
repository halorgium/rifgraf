$(function () {
  var options = {
      xaxis: { mode: "time" },
      selection: { mode: "x" }
      //grid: { markings: weekendAreas }
  };
  var overview  = $("#overview");
  var fullgraph = $("#fullgraph");

  var onDataReceived = function (json) {
    var data = json.graphs;
    var fullgraphP = $.plot(fullgraph, data, options);

    var overviewP = $.plot(overview, data, {
      series: {
          lines: { show: true, lineWidth: 1 },
          shadowSize: 0,
      },
      legend: {
        show: false
      },
      xaxis: { ticks: [], mode: "time" },
      yaxis: { ticks: [], min: 0, autoscaleMargin: 0.1 },
      selection: { mode: "x" }
    });

    fullgraph.bind("plotselected", function (event, ranges) {
      var axes = {
        xaxis: { min: ranges.xaxis.from, max: ranges.xaxis.to }
      };
      fullgraphP = $.plot(fullgraph, data, $.extend(true, {}, options, axes));

      // don't fire event on the overview to prevent eternal loop
      overviewP.setSelection(ranges, true);
    });

    overview.bind("plotselected", function (event, ranges) {
      fullgraphP.setSelection(ranges);
    });
  };

  $.ajax({
    url: "/" + graphNames.join(),
    method: 'GET',
    dataType: 'json',
    success: onDataReceived
  });
});
