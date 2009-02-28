const POWER = 0;
const SPEED = 1;
const CADENCE = 2;
const HEARTRATE = 1;
var time_series;
var data_series;
    
var global_options = {
	grid: { 
		backgroundColor:'#FFFFFF' }, 
 	xaxis: {
   	tickFormatter: xAxisFormatter
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
   	location: 'ne'
 	}, 
 	shadowSize: 2
} 

function xAxisFormatter(label) {
  var i=Math.round(label)-1;
  if(i<0) return;
  return time_series[0]['data'][i][1];

}
 
function drawPlot (series, options) {
  var opts = Object.extend(Object.clone(global_options), options || {});
  create_labels(series);
  return Flotr.draw($('plot'), smooth_data(series), opts);
}

function create_labels(series) {
  label_template = new Template('<tr id="#{label}"><td align="right">#{name} :</td><td><span id="#{selected}">0</span> <span>#{units}</span></td></tr>');
  series.each(function(s, i) {
    if($('label_' + i) != null) $('label_' + i).remove();
    $('graph_labels').firstDescendant().insert(label_template.evaluate({
      name: s.label,
			units: s.units,
      label: "label_" + i,
      selected: "selected_" + i,
    }));  
  });
  
}

function slice_data(series, start, end) {
  var sliced = new Array(series.size());
  
  series.each(function(s, i) {
    sliced[i] = new Object();
    sliced[i].label = s.label;
		sliced[i].color = s.color;	
    sliced[i].data = s.data.slice(start, end);
  });
  //sliced[POWER].label = series[POWER].label;
  //sliced[POWER].data = series[POWER]['data'].slice(start, end)
  //sliced[HEARTRATE].label = series[HEARTRATE].label;
  //sliced[HEARTRATE].data = series[HEARTRATE]['data'].slice(start, end)
  return sliced;
}

function smooth_data(series) { 
   
  //var smoothed_data = [Object(), Object()];
  var smoothed_data = new Array(series.size());
  if(series.size()>0) {
		var size = (series[0]['data'].length>500) ? Math.round(series[0]['data'].length/500) : 1;
		series.each(function(s, i) {
	    smoothed_data[i] = Object();
	    smoothed_data[i].label = s.label;
			smoothed_data[i].color = s.color;
	    smoothed_data[i].data = s.data.eachSlice(size, function(point) { return point.first(); } );
	  });
	}
	 return smoothed_data;	  
}

$('plot').observe('flotr:mousemove', function(event){
  var pos = event.memo[1];
  var x=Math.round(pos.x);
  if(x<0) return;
  $('selected_time').innerHTML = time_series[0]['data'][x][1];
  
  data_series.each(function(s, i) {
    $('selected_' + i).innerHTML = s.data[x][1];
  });
  //$('selected_power').innerHTML = data_series[POWER]['data'][i][1];
  
});	

$('plot').observe('mouseout', function(event){
  $('selected_time').innerHTML = '00:00:00' 
  data_series.each(function(s, i) {
    $('selected_' + i).innerHTML = '0';
  });
});

$('plot').observe('flotr:select', function(event){
	var selection = event.memo[0];
 	var begin = Math.round(selection.x1);
 	var end = Math.round(selection.x2);
  var f = drawPlot(slice_data(data_series, begin, end));
 	Element.show('zoom_reset');
});

$('zoom_reset').observe('click', function() { 
	drawPlot(data_series, {}); Element.hide('zoom_reset'); 
});
