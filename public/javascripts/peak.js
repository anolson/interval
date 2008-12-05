var time_series;
var data_series;
    
var global_options = {
	grid: { 
		backgroundColor:'#FFFFFF' }, 
 	xaxis: {
   	tickFormatter: xAxisFormatter
 	},
	mouse: { 
   	lineColor: '#444444', 
   	sensibility: 10, 
   	track: true,
		trackFormatter: trackFormatter
	},
	legend: {
 	backgroundOpacity: 0.85,
   	show: true,
   	location: 'ne'
 	}, 
} 

function xAxisFormatter(label) {
  var i=Math.round(label)-1;
  if(i<0) return;
  return time_series[0]['data'][i][1];
}
 
function trackFormatter(point) {
	return "Power: " + point.y;
}

function drawPlot (series, options) {
  var opts = Object.extend(Object.clone(global_options), options || {});
  return Flotr.draw($('plot'), series, opts);
}


