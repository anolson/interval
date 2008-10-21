const POWER = 0;
const SPEED = 1;
const CADENCE = 2;
const HEARTRATE = 3;
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
 	shadowSize: 0
} 

function xAxisFormatter(label) {
  var i=Math.round(label)-1;
  if(i<0) return;
  return time_series[0]['data'][i][1];

}
 
function drawPlot (series, options) {
  var opts = Object.extend(Object.clone(global_options), options || {});
  return Flotr.draw($('plot'), smooth_data(series), opts);
}

function slice_data(series, start, end) {
  var sliced = [Object()];
  sliced[POWER].label = series[POWER].label;
  sliced[POWER].data = series[POWER]['data'].slice(start, end)
  return sliced;
}

function smooth_data(series) { 
  var size = (series[POWER]['data'].length>1000) ? Math.round(series[POWER]['data'].length/1000) : 1; 
  var smoothed_data = [Object()];
  smoothed_data[POWER].label = series[POWER].label;
  smoothed_data[POWER]['data'] = series[POWER]['data'].eachSlice(size, function(point) { return point.first(); } );  
 	return smoothed_data;	  
}

$('plot').observe('flotr:mousemove', function(event){
   var pos = event.memo[1];
   var i=Math.round(pos.x);
   if(i<0) return;
   $('selected_time').innerHTML = time_series[0]['data'][i][1];
   $('selected_power').innerHTML = data_series[POWER]['data'][i][1];
});	

$('plot').observe('mouseout', function(event){
  $('selected_time').innerHTML = '00:00:00' 
	$('selected_power').innerHTML = '0' 
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
