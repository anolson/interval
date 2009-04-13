var time_series;
var data_series;
var plot;
var zoom_on_selection;
var previous_marker_id;
    
var global_options = {
	grid: { 
		backgroundColor:'#FFFFFF' }, 
 	xaxis: {
   	tickFormatter: xAxisFormatter,
		noTicks: 9
	},
	yaxis: {
		noTicks: 6
	},
 	selection: {
   	mode: 'x'
 	},
	mouse: { 
   	lineColor: '#444444', 
   	sensibility: 2, 
   	track: false
	},
	legend: {
    backgroundOpacity: 0.85,
   	show: true,
   	position: 'ne'
 	}, 
 	shadowSize: 1
} 

function xAxisFormatter(label) {
  var i=Math.round(label)-1;
  if(i<0) return;
  return time_series[0]['data'][i][1];

}
 
function loadWorkoutPlot(url) {
  resizePlot();
  
  Event.observe(window, 'resize', function() { 
    resizePlot();
    redrawPlot();
  });
              
  document.observe('dom:loaded', function() {
    new Ajax.Request(url, {
      method:'get',
      onSuccess: function(transport){
        var json = transport.responseText.evalJSON();
        data_series = json.data_series
        time_series = json.time_series

        if(data_series){
          $('plot').setStyle({'display':'block'});

           plot = drawPlot(data_series);
         }
      }
    });
  });
}
 
function drawPlot (series, options) {
  var opts = Object.extend(Object.clone(global_options), options || {});
  create_labels(series);
  return Flotr.draw($('plot'), smooth_data(series), opts);
  
}

function resizePlot() {
	$('plot').setStyle({width:$('plot_wrapper').getWidth() * .95} );
	Element.hide('zoom_reset');
}

function redrawPlot() {
  plot = drawPlot(data_series);
}


function create_labels(series) {
  label_template = new Template('<td id="#{label}" align="center">#{name} : <span id="#{selected}">0</span> <span>#{units}</span></td>');
  
  series.each(function(s, i) {
    if($('label_' + i) != null) $('label_' + i).remove();
    $('graph_labels').firstDescendant().firstDescendant().insert(label_template.evaluate({
      name: s.label,
			units: s.units,
      label: "label_" + i,
      selected: "selected_" + i
    }));
  });
  
}

function slice_data(series, start, end) {
  var sliced = new Array(series.size());
  
  series.each(function(s, i) {
    sliced[i] = new Object();
    sliced[i].label = s.label;
		sliced[i].units = s.units;
		sliced[i].color = s.color;	
    sliced[i].data = s.data.slice(start, end);
  });

  return sliced;
}

function smooth_data(series) { 
  var smoothed_data = new Array(series.size());
  if(series.size()>0) {
		var size = (series[0]['data'].length>500) ? Math.round(series[0]['data'].length/500) : 1;
		series.each(function(s, i) {
	    smoothed_data[i] = Object();
	    smoothed_data[i].label = s.label;
			smoothed_data[i].units = s.units;
			smoothed_data[i].color = s.color;
	    smoothed_data[i].data = s.data.eachSlice(size, function(point) { return point.first(); } );
	  });
	}
	 return smoothed_data;	  
}

function select_marker(id, start, end) {
	set_marker_selection(start, end);
  hide_previous_marker_details(id);
	display_marker_details(id);
}

function set_marker_selection(start, end) {
	zoom_on_selection = false;
  plot.setSelection({x1:start, x2:end})	
}

function hide_previous_marker_details(id) {
  if(previous_marker_id && previous_marker_id != id) {
    $('marker_details_' + previous_marker_id).hide();
  }
}

function display_marker_details(id) {
	marker_details_id = 'marker_details_' + id
  
	if(!$(marker_details_id).visible()) {
    previous_marker_id = id;
	}
	else {
    previous_marker_id = null;
    plot.clearSelection();
	}
  $(marker_details_id).toggle();


}

$('plot').observe('flotr:mousemove', function(event){
  var pos = event.memo[1];
  var x=Math.round(pos.x);
  if(x<0) return;
  $('selected_time').innerHTML = time_series[0]['data'][x][1];
  
  data_series.each(function(s, i) {
    if(s.label=='Speed') {
			$('selected_' + i).innerHTML = (s.data[x][1]/10).toFixed(1);
		}
		else {
			$('selected_' + i).innerHTML = s.data[x][1];
		}
    
  });
  zoom_on_selection=true;
});	

$('plot').observe('mouseout', function(event){
  $('selected_time').innerHTML = '00:00:00' 
  data_series.each(function(s, i) {
    $('selected_' + i).innerHTML = '0';
  });
});


$('plot').observe('flotr:select', function(event){
	if(zoom_on_selection == true) {
		var selection = event.memo[0];
 		var begin = Math.round(selection.x1);
 		var end = Math.round(selection.x2);
  	plot = drawPlot(slice_data(data_series, begin, end));
 		Element.show('zoom_reset');
	}
});

$('zoom_reset').observe('click', function() { 
	plot = drawPlot(data_series, {}); 
	Element.hide('zoom_reset'); 
});
