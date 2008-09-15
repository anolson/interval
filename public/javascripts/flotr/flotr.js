var Flotr = {
	version: '%version%',
	author: 'Bas Wenneker',
	website: 'http://www.solutoire.com',
	/**
	 * An object of the default registered grpah types. Use Flotr.register(type, functionName)
	 * to add your own type.
	 */
	_registeredTypes:{
		'lines': 'drawSeriesLines',
		'points': 'drawSeriesPoints',
		'bars': 'drawSeriesBars'
	},
	/**
	 * Can be used to register your own chart type. Default types are 'lines', 'points' and 'bars'.
	 * This is still experimental.
	 * @todo Test and confirm.
	 * @param {String} type - type of chart, like 'pies', 'bars' etc.
	 * @param {String} functionName - Name of the draw function, like 'drawSeriesPies', 'drawSeriesBars' etc.
	 */
	register: function(type, functionName){		
		Flotr._registeredTypes[type] = functionName+'';	
	},
	/**
	 * Draws the graph. This function is here for backwards compatibility with Flotr version 0.1.0alhpa.
	 * You could also draw graphs by directly calling Flotr.Graph(element, data, options).
	 * @param {Element} el - element to insert the graph into
	 * @param {Object} data - an array or object of dataseries
	 * @param {Object} options - an object containing options
	 * @param {Class} _GraphKlass_ - (optional) Class to pass the arguments to, defaults to Flotr.Graph
	 * @return {Class} returns a new graph object and of course draws the graph.
	 */
	draw: function(el, data, options, _GraphKlass_){	
		_GraphKlass_ = _GraphKlass_ || Flotr.Graph;
		return new _GraphKlass_(el, data, options);
	},
	/**
	 * Collects dataseries from input and parses the series into the right format. It returns an Array 
	 * of Objects each having at least the 'data' key set.
	 * @param {Array/Object} data - Object or array of dataseries
	 * @return {Array} Array of Objects parsed into the right format ({(...,) data: [[x1,y1], [x2,y2], ...] (, ...)})
	 */
	getSeries: function(data){
		return data.collect(function(serie){
			return (serie.data) ? Object.clone(serie) : {'data': serie};
		});
	},
	/**
	 * Recursively merges two objects.
	 * @param {Object} src - source object (likely the object with the least properties)
	 * @param {Object} dest - destination object (optional, object with the most properties)
	 * @return {Object} recursively merged Object
	 */
	merge: function(src, dest){
		var result = dest || {};
		for(var i in src){		  
			result[i] = (src[i] != null && typeof(src[i]) == 'object' && !(src[i].constructor == Array || src[i].constructor == RegExp)) ? Flotr.merge(src[i], dest[i]) : result[i] = src[i];		
		}
		return result;	
	},	
	/**
	 * Function calculates the ticksize and returns it.
	 * @param {Integer} noTicks - number of ticks
	 * @param {Integer} min - lower bound integer value for the current axis
	 * @param {Integer} max - upper bound integer value for the current axis
	 * @param {Integer} decimals - number of decimals for the ticks
	 * @return {Integer} returns the ticksize in pixels
	 */
	getTickSize: function(noTicks, min, max, decimals){
		var delta = (max - min) / noTicks;	
		var magn = Flotr.getMagnitude(delta);
		
		// Norm is between 1.0 and 10.0.
		var norm = delta / magn;
		
		var tickSize = 10;
		if(norm < 1.5) tickSize = 1;
		else if(norm < 2.25) tickSize = 2;
		else if(norm < 3) tickSize = ((decimals == 0) ? 2 : 2.5);
		else if(norm < 7.5) tickSize = 5;
				
		return tickSize * magn;
	},
	/**
	 * Default tick formatter.
	 * @param {String/Integer} val - tick value integer
	 * @return {String} formatted tick string
	 */
	defaultTickFormatter: function(val){
		return val+'';
	},
	/**
	 * Formats the mouse tracker values.
	 * @param {Object} obj - Track value Object {x:..,y:..}
	 * @return {String} Formatted track string
	 */
	defaultTrackFormatter: function(obj){
		return '('+obj.x+', '+obj.y+')';
	}, 
	/**
	 * Returns the magnitude of the input value.
	 * @param {Integer/Float} x - integer or float value
	 * @return {Integer/Float} returns the magnitude of the input value
	 */
	getMagnitude: function(x){
		return Math.pow(10, Math.floor(Math.log(x) / Math.LN10));
	},
	/**
	 * Parses a color string and returns a corresponding Color.
	 * @param {String} str - string thats representing a color
	 * @return {Color} returns a Color object or false
	 */
	parseColor: function(str){
		var result, Color = Flotr.Color;
	
		// rgb(num,num,num)
		if((result = /rgb\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*\)/.exec(str)))
			return new Color(parseInt(result[1]), parseInt(result[2]), parseInt(result[3]));
	
		// rgba(num,num,num,num)
		if((result = /rgba\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]+(?:\.[0-9]+)?)\s*\)/.exec(str)))
			return new Color(parseInt(result[1]), parseInt(result[2]), parseInt(result[3]), parseFloat(result[4]));
			
		// rgb(num%,num%,num%)
		if((result = /rgb\(\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*\)/.exec(str)))
			return new Color(parseFloat(result[1])*2.55, parseFloat(result[2])*2.55, parseFloat(result[3])*2.55);
	
		// rgba(num%,num%,num%,num)
		if((result = /rgba\(\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\s*\)/.exec(str)))
			return new Color(parseFloat(result[1])*2.55, parseFloat(result[2])*2.55, parseFloat(result[3])*2.55, parseFloat(result[4]));
			
		// #a0b1c2
		if((result = /#([a-fA-F0-9]{2})([a-fA-F0-9]{2})([a-fA-F0-9]{2})/.exec(str)))
			return new Color(parseInt(result[1],16), parseInt(result[2],16), parseInt(result[3],16));
	
		// #fff
		if((result = /#([a-fA-F0-9])([a-fA-F0-9])([a-fA-F0-9])/.exec(str)))
			return new Color(parseInt(result[1]+result[1],16), parseInt(result[2]+result[2],16), parseInt(result[3]+result[3],16));

		// Otherwise, we're most likely dealing with a named color.
		var name = str.strip().toLowerCase();
		if(name == 'transparent'){
			return new Color(255, 255, 255, 0);
		}
		return ((result = Color.lookupColors[name])) ? new Color(result[0], result[1], result[2]) : false;
	},
	/**
	 * Extracts the background-color of the passed element.
	 * @param {Element} element
	 * @return {String} color string
	 */
	extractColor: function(element){
		var color;
		// Loop until we find an element with a background color and stop when we hit the body element. 
		do{
			color = element.getStyle('background-color').toLowerCase();
			if(!(color == '' || color == 'transparent')) break;			
			element = element.up(0);
		}while(element.nodeName.toLowerCase() != 'body');

		// Catch Safari's way of signalling transparent.
		return (color == 'rgba(0, 0, 0, 0)') ? 'transparent' : color;
	}
};
/**
 * Flotr Graph class that plots a graph on creation.

 */
Flotr.Graph = Class.create({
	/**
	 * Flotr Graph constructor.
	 * @param {Element} el - element to insert the graph into
	 * @param {Object} data - an array or object of dataseries
 	 * @param {Object} options - an object containing options
	 */
	initialize: function(el, data, options){
		this.el = el;
		this.data = data;
		this.series = Flotr.getSeries(data);
		this.setOptions(options);
		// Create and prepare canvas.
		this.constructCanvas();
		// Add event handlers for mouse tracking, clicking and selection
		this.initEvents();
		this.findDataRanges();
		this.calculateTicks(this.xaxis, this.options.xaxis);
		this.calculateTicks(this.yaxis, this.options.yaxis);		
		this.calculateSpacing();
		this.draw();		
		this.insertLegend();	
	},
	/**
	 * Sets options and initializes some variables and color specific values, used by the constructor. 
	 * @param {Object} opts - options object
	 */
	setOptions: function(opts){		
		this.options = Flotr.merge((opts || {}), {
			colors: ['#00A8F0', '#C0D800', '#cb4b4b', '#4da74d', '#9440ed'], //=> The default colorscheme. When there are > 5 series, additional colors are generated.
			legend: {
				show: true,				// => setting to true will show the legend, hide otherwise
				noColumns: 1,			// => number of colums in legend table
				labelFormatter: null,	// => fn: string -> string
				labelBoxBorderColor: '#ccc', // => border color for the little label boxes
				container: null,			// => container (as jQuery object) to put legend in, null means default on top of graph
				position: 'ne',			// => position of default legend container within plot
				margin: 5,				// => distance from grid edge to default legend container within plot
				backgroundColor: null,	// => null means auto-detect
				backgroundOpacity: 0.85	// => set to 0 to avoid background, set to 1 for a solid background
			},
			xaxis: {
				ticks: null,			// => format: either [1, 3] or [[1, 'a'], 3]
				noTicks: 5,				// => number of ticks for automagically generated ticks
				tickFormatter: Flotr.defaultTickFormatter, // => fn: number -> string
				tickDecimals: null,		// => no. of decimals, null means auto
				min: null,				// => min. value to show, null means set automatically
				max: null,				// => max. value to show, null means set automatically
				autoscaleMargin: 0		// => margin in % to add if auto-setting min/max
			},
			yaxis: {
				ticks: null,			// => format: either [1, 3] or [[1, 'a'], 3]
				noTicks: 5,				// => number of ticks for automagically generated ticks
				tickFormatter: Flotr.defaultTickFormatter, // => fn: number -> string
				tickDecimals: null,		// => no. of decimals, null means auto
				min: null,				// => min. value to show, null means set automatically
				max: null,				// => max. value to show, null means set automatically
				autoscaleMargin: 0		// => margin in % to add if auto-setting min/max
			},
			points: {
				show: false,			// => setting to true will show points, false will hide
				radius: 3,				// => point radius (pixels)
				lineWidth: 2,			// => line width in pixels
				fill: true,				// => true to fill the points with a color, false for (transparent) no fill
				fillColor: '#ffffff',	// => fill color
				fillOpacity: 0.4
			},
			lines: {
				show: false,			// => setting to true will show lines, false will hide
				lineWidth: 2, 			// => line width in pixels
				fill: false,			// => true to fill the area from the line to the x axis, false for (transparent) no fill
				fillColor: null,		// => fill color
				fillOpacity: 0.4		// => opacity of the fill color, set to 1 for a solid fill, 0 hides the fill
			},
			bars: {
				show: false,			// => setting to true will show bars, false will hide
				lineWidth: 2,			// => in pixels
				barWidth: 1,			// => in units of the x axis
				fill: true,				// => true to fill the area from the line to the x axis, false for (transparent) no fill
				fillColor: null,		// => fill color
				fillOpacity: 0.4,		// => opacity of the fill color, set to 1 for a solid fill, 0 hides the fill
				horizontal: false
			},
			grid: {
				color: '#545454',		// => primary color used for outline and labels
				backgroundColor: null,	// => null for transparent, else color
				tickColor: '#dddddd',	// => color used for the ticks
				labelMargin: 3,			// => margin in pixels
				verticalLines: true,	// => whether to show gridlines in vertical direction
				horizontalLines: true,	// => whether to show gridlines in horizontal direction
				outlineWidth: 2			// => width of the grid outline/border in pixels
			},
			selection: {
				mode: null,				// => one of null, 'x', 'y' or 'xy'
				color: '#B6D9FF',		// => selection box color
				fps: 10					// => frames-per-second
			},
			mouse: {
				track: null,			// => true to track the mouse, no tracking otherwise
				position: 'se',			// => position of the value box (default south-east)
				trackFormatter: Flotr.defaultTrackFormatter, // => formats the values in the value box
				margin: 3,				// => margin in pixels of the valuebox
				lineColor: '#ff3f19',		// => line color of points that are drawn when mouse comes near a value of a series
				trackDecimals: 1,		// => decimals for the track values
				sensibility: 2,			// => the lower this number, the more precise you have to aim to show a value
				radius: 3				// => radius of the tracck point
			},
			shadowSize: 4,				// => size of the 'fake' shadow
			defaultType: 'lines'		// => default series type
		});
				
		// Initialize some variables used throughout this function.
		var assignedColors = [],
			colors = [],
			ln = this.series.length,
			neededColors = this.series.length,
			oc = this.options.colors, 
			usedColors = [], 			
			variation = 0,
			c, i, j, s;
			
		// Collect user-defined colors from series.
		for(i = neededColors - 1; i > -1; --i){
			c = this.series[i].color;
			if(c != null){
				--neededColors;
				if(Object.isNumber(c)) assignedColors.push(c);
				else usedColors.push(Flotr.parseColor(c));
			}
		}
		
		// Calculate the number of colors that need to be generated.
		for(i = assignedColors.length - 1; i > -1; --i)
			neededColors = Math.max(neededColors, assignedColors[i] + 1);
			
		// Generate needed number of colors.
		for(i = 0; colors.length < neededColors;){
			c = (oc.length == i) ? new Flotr.Color(100, 100, 100) : Flotr.parseColor(oc[i]);
			
			// Make sure each serie gets a different color.
			var sign = variation % 2 == 1 ? -1 : 1;
			var factor = 1 + sign * Math.ceil(variation / 2) * 0.2;
			c.scale(factor, factor, factor);

			/**
			 * @todo if we're getting to close to something else, we should probably skip this one
			 */
			colors.push(c);
			
			if(++i >= oc.length){
				i = 0;
				++variation;
			}
		}
	
		// Fill the options with the generated colors.
		for(i = 0, j = 0; i < ln; ++i){
			s = this.series[i];

			// Assign the color.
			if(s.color == null){
				s.color = colors[j++].toString();
			}else if(Object.isNumber(s.color)){
				s.color = colors[s.color].toString();
			}
			
			// Apply missing options to the series.
			s.lines = Object.extend(Object.clone(this.options.lines), s.lines);
			s.points = Object.extend(Object.clone(this.options.points), s.points);
			s.bars = Object.extend(Object.clone(this.options.bars), s.bars);
			s.mouse = Object.extend(Object.clone(this.options.mouse), s.mouse);
			
			if(s.shadowSize == null) s.shadowSize = this.options.shadowSize;
		}
		
		// Finally, initialize some variables.
		/**
		 * @todo find a better place for initialization, maybe move this to the constructor
		 */
		this.lastMousePos = { pageX: null, pageY: null };
		this.selection = { first: { x: -1, y: -1}, second: { x: -1, y: -1} };
		this.prevSelection = null;
		this.selectionInterval = null;
		this.ignoreClick = false;		
		this.prevHit = null;
	},
	/**
	 * Initializes the canvas and it's overlay canvas element. When the browser is IE, this makes use 
	 * of excanvas. The overlay canvas is inserted for displaying interactions. After the canvas elements
	 * are created, the elements are inserted into the container element.
	 */
	constructCanvas: function(){
		var el = this.el,			
			size, c, oc;
		el.innerHTML = '';
		this.canvasWidth = el.getWidth();
		this.canvasHeight = el.getHeight();
		size = {'width': this.canvasWidth,	'height': this.canvasHeight};
		
		// For positioning labels and overlay.
		el.setStyle({position: 'relative',cursor:'default'});		
		if(this.canvasWidth <= 0 || this.canvasHeight <= 0){
			throw 'Invalid dimensions for plot, width = ' + this.canvasWidth + ', height = ' + this.canvasHeight;
		}

		// Insert main canvas.
		c = this.canvas = $(document.createElement('canvas')).writeAttribute(size);
		c.className = 'flotr-canvas';		
		el.appendChild(c);
		if(Prototype.Browser.IE){
			c = $(window.G_vmlCanvasManager.initElement(c));
		} 
		this.ctx = c.getContext('2d');

		// Insert overlay canvas for interactive features.	
		oc = this.overlay = $(document.createElement('canvas')).writeAttribute(size);
		oc.className = 'flotr-overlay';		
		el.appendChild(oc.writeAttribute('style', 'position:absolute;left:0px;top:0px;'));				
		
		if(Prototype.Browser.IE){
			oc = window.G_vmlCanvasManager.initElement(oc);
		}		
		this.octx = oc.getContext('2d');		
	},
	/**
	 * Initializes event some handlers.
	 */
	initEvents: function () {
		if(this.options.selection.mode != null)
			this.overlay.observe('mousedown', this.mouseDownHandler.bind(this));				
							
		this.overlay.observe('mousemove', this.mouseMoveHandler.bind(this));
		this.overlay.observe('click', this.clickHandler.bind(this));
	},
	/**
	 * Function determines the min and max values for the xaxis and yaxis.
	 */
	findDataRanges: function(){
		this.yaxis = {datamin: 0, datamax: 1};	
		this.xaxis = {datamin: 0, datamax: 1};	
		var s = this.series;
		if(s.length > 0){
			var found = false,
				i, j, h, x, y, data;
			
			// Get datamin, datamax start values 
			for(i = 0; i < s.length; ++i){
				if (s[i].data.length > 0) {
					this.xaxis.datamin = this.xaxis.datamax = s[i].data[0][0];
					this.yaxis.datamin = this.yaxis.datamax = s[i].data[0][1];
					found = true;
					break;
				}
			}
			
			// Return because series are empty.
			if(!found) return;
	
			// ...then find real datamin, datamax.
			for(j = s.length - 1; j > -1; --j){
				data = s[j].data;
				for(h = data.length - 1; h > -1; --h){
					x = data[h][0];
					y = data[h][1];
					if(x < this.xaxis.datamin) this.xaxis.datamin = x;
					else if(x > this.xaxis.datamax) this.xaxis.datamax = x;
					if(y < this.yaxis.datamin) this.yaxis.datamin = y;
					else if(y > this.yaxis.datamax) this.yaxis.datamax = y;
				}
			}
		}
		this.calculateRange(this.xaxis, this.options.xaxis);
		this.extendXRangeIfNeededByBar();
		this.calculateRange(this.yaxis, this.options.yaxis);
		this.extendYRangeIfNeededByBar();
	},
	/**
	 * Calculates the range of an axis to apply autoscaling.
	 */
	calculateRange: function(axis, o){
		var min = o.min != null ? o.min : axis.datamin,
			max = o.max != null ? o.max : axis.datamax,
			margin;
				
		if(max - min == 0.0){
			var widen = (max == 0.0) ? 1.0 : 0.01;
			min -= widen;
			max += widen;
		}			
		axis.tickSize = Flotr.getTickSize(o.noTicks, min, max, o.tickDecimals);
			
		// Autoscaling.
		if(o.min == null){			
			// Add a margin.
			margin = o.autoscaleMargin;
			if(margin != 0){
				min -= axis.tickSize * margin;				
				
				// Make sure we don't go below zero if all values are positive.
				if(min < 0 && axis.datamin >= 0) min = 0;				
				min = axis.tickSize * Math.floor(min / axis.tickSize);
			}
		}
		if(o.max == null){
			margin = o.autoscaleMargin;
			if(margin != 0){
				max += axis.tickSize * margin;
				if(max > 0 && axis.datamax <= 0) max = 0;				
				max = axis.tickSize * Math.ceil(max / axis.tickSize);
			}
		}
		axis.min = min;
		axis.max = max;
	},
	/**
	 * Bar series autoscaling in x direction.
	 */
	extendXRangeIfNeededByBar: function(){
		if(this.options.xaxis.max == null){
			var newmax = this.xaxis.max,
				i, b;
				
			for(i = this.series.length - 1; i > -1; --i){				
				b = this.series[i].bars;
				if(b.show && !b.horizontal && b.barWidth + this.xaxis.datamax > newmax){
					newmax = this.xaxis.max + this.series[i].bars.barWidth;
				}
			}
			this.xaxis.max = newmax;
		}
	},
	/**
	 * Bar series autoscaling in y direction.
	 */
	extendYRangeIfNeededByBar: function(){
		if(this.options.yaxis.max == null){
			var newmax = this.yaxis.max,
				i, b;
								
			for(i = this.series.length - 1; i > -1; --i){
				b = this.series[i].bars;
				if(b.show && b.horizontal && b.barWidth + this.yaxis.datamax > newmax){
					newmax = this.yaxis.max + b.barWidth;
				}
			}
			this.yaxis.max = newmax;
		}
	},
	/**
	 * Calculate axis ticks.
	 * @param {Object} axis - axis object
	 * @param {Object} o - axis options
	 */
	calculateTicks: function(axis, o){
		axis.ticks = [];	
		if(o.ticks){
			var ticks = o.ticks,
				i, t, v, label;

			if(Object.isFunction(ticks)){
				ticks = ticks({ min: axis.min, max: axis.max });
			}
			
			// Clean up the user-supplied ticks, copy them over.
			for(i = 0; i < ticks.length; ++i){
				t = ticks[i];
				if(typeof(t) == 'object'){
					v = t[0];
					label = (t.length > 1) ? t[1] : o.tickFormatter(v);
				}else{
					v = t;
					label = o.tickFormatter(v);
				}
				axis.ticks[i] = { v: v, label: label };
			}
		}else{
			// Round to nearest multiple of tick size.
			var start = axis.tickSize * Math.ceil(axis.min / axis.tickSize),
				i, v, decimals;
			
			// Then store all possible ticks.
			for(i = 0; start + i * axis.tickSize <= axis.max; ++i){
				v = start + i * axis.tickSize;
				
				// Round (this is always needed to fix numerical instability).
				decimals = o.tickDecimals;
				if(decimals == null) decimals = 1 - Math.floor(Math.log(axis.tickSize) / Math.LN10);
				if(decimals < 0) decimals = 0;
				
				v = v.toFixed(decimals);
				axis.ticks.push({ v: v, label: o.tickFormatter(v) });
			}
		}
	},
	/**
	 * Calculates axis label sizes.
	 */
	calculateSpacing: function(){
		var max_label = '',
			options = this.options,
			series = this.series,
			y = this.yaxis,
			x = this.xaxis,
			maxOutset = 2,
			i, j, l;
			
		for(i = 0; i < y.ticks.length; ++i){
			l = y.ticks[i].label.length;
			if(l > max_label.length){
				max_label = y.ticks[i].label;
			}
		}	
		var dummyDiv = this.el.insert('<div style="position:absolute;top:-10000px;font-size:smaller" class="flotr-grid-label">' + max_label + '</div>').down(0).next(1);
		this.labelMaxWidth = dummyDiv.getWidth();
		this.labelMaxHeight = dummyDiv.getHeight();
		dummyDiv.remove();

		// Grid outline line width.
		if(options.show){
			maxOutset = Math.max(maxOutset, options.points.radius + options.points.lineWidth/2);
		}
		for(j = 0; j < options.length; ++j){
			if (series[j].points.show){
				maxOutset = Math.max(maxOutset, series[j].points.radius + series[j].points.lineWidth/2);
			}
		}
		
		this.plotOffset = p = {left: 0, right: 0, top: 0, bottom: 0};
		p.left = p.right = p.top = p.bottom = maxOutset;
		p.left += this.labelMaxWidth + options.grid.labelMargin;
		p.bottom += this.labelMaxHeight + options.grid.labelMargin;			
		this.plotWidth = this.canvasWidth - p.left - p.right;
		this.plotHeight = this.canvasHeight - p.bottom - p.top;
		this.hozScale = this.plotWidth / (x.max - x.min);
		this.vertScale = this.plotHeight / (y.max - y.min);
	},
	/**
	 * Draws grid, labels and series.
	 */
	draw: function() {
		this.drawGrid();
		
		this.drawLabels();
		if(this.series.length){
			this.el.fire('flotr:beforedraw', [this.series, this]);
			for(var i = 0; i < this.series.length; i++){
				this.drawSeries(this.series[i]);
			}
		}
		this.el.fire('flotr:afterdraw', [this.series, this]);
	},
	/**
	 * Translates absolute horizontal x coordinates to relative coordinates.
	 * @param {Integer} x - absolute integer x coordinate
	 * @return {Integer} translated relative x coordinate
	 */
	tHoz: function(x){
		return (x - this.xaxis.min) * this.hozScale;
	},
	/**
	 * Translates absolute vertical x coordinates to relative coordinates.
	 * @param {Integer} y - absolute integer y coordinate
	 * @return {Integer} translated relative y coordinate
	 */
	tVert: function(y){
		return this.plotHeight - (y - this.yaxis.min) * this.vertScale;
	},
	/**
	 * Draws a grid for the graph.
	 */
	drawGrid: function(){
		var o = this.options,
			ctx = this.ctx;
		if(o.grid.verticalLines || o.grid.horizontalLines){			
			this.el.fire('flotr:beforegrid', [this.xaxis, this.yaxis, o, this]);
		}
		ctx.save();
		ctx.translate(this.plotOffset.left, this.plotOffset.top);

		// Draw grid background, if present in options.
		if(o.grid.backgroundColor != null){
			ctx.fillStyle = o.grid.backgroundColor;
			ctx.fillRect(0, 0, this.plotWidth, this.plotHeight);
		}
		
		// Draw grid lines in vertical direction.
		ctx.lineWidth = 1;
		ctx.strokeStyle = o.grid.tickColor;
		ctx.beginPath();
		if(o.grid.verticalLines){
			for(var i = 0, v = null; i < this.xaxis.ticks.length; ++i){
				v = this.xaxis.ticks[i].v;
				// Don't show lines on upper and lower bounds.
				if ((v == this.xaxis.min || v == this.xaxis.max) && o.grid.outlineWidth != 0)
					continue;
	
				ctx.moveTo(Math.floor(this.tHoz(v)) + ctx.lineWidth/2, 0);
				ctx.lineTo(Math.floor(this.tHoz(v)) + ctx.lineWidth/2, this.plotHeight);
			}
		}
		
		// Draw grid lines in horizontal direction.
		if(o.grid.horizontalLines){
			for(var j = 0, v = null; j < this.yaxis.ticks.length; ++j){
				v = this.yaxis.ticks[j].v;
				// Don't show lines on upper and lower bounds.
				if ((v == this.yaxis.min || v == this.yaxis.max) && o.grid.outlineWidth != 0)
					continue;
	
				ctx.moveTo(0, Math.floor(this.tVert(v)) + ctx.lineWidth/2);
				ctx.lineTo(this.plotWidth, Math.floor(this.tVert(v)) + ctx.lineWidth/2);
			}
		}
		ctx.stroke();
		
		// Draw axis/grid border.
		if(o.grid.outlineWidth != 0) {
			ctx.lineWidth = o.grid.outlineWidth;
			ctx.strokeStyle = o.grid.color;
			ctx.lineJoin = 'round';
			ctx.strokeRect(0, 0, this.plotWidth, this.plotHeight);
		}
		ctx.restore();
		if(o.grid.verticalLines || o.grid.horizontalLines){			
			this.el.fire('flotr:aftergrid', [this.xaxis, this.yaxis, o, this]);
		}
	},
	/**
	 * Draws labels for x and y axis.
	 */   
	drawLabels: function(){		
		// Construct fixed width label boxes, which can be styled easily. 
		var noLabels = 0,
			xBoxWidth, i, html, tick;
			
		for(i = 0; i < this.xaxis.ticks.length; ++i){
			if (this.xaxis.ticks[i].label) {
				++noLabels;
			}
		}
		xBoxWidth = this.plotWidth / noLabels;
		html = ['<div style="font-size:smaller;color:' + this.options.grid.color + '">'];
		
		// Add xlabels.
		for(i = 0; i < this.xaxis.ticks.length; ++i){
			tick = this.xaxis.ticks[i];
			if(!tick.label) continue;
			html.push('<div style="position:absolute;top:' + (this.plotOffset.top + this.plotHeight + this.options.grid.labelMargin) + 'px;left:' + (this.plotOffset.left + this.tHoz(tick.v) - xBoxWidth/2) + 'px;width:' + xBoxWidth + 'px;text-align:center" class="flotr-grid-label">' + tick.label + '</div>');
		}
		
		// Add ylabels.
		for(i = 0; i < this.yaxis.ticks.length; ++i){
			tick = this.yaxis.ticks[i];
			if (!tick.label || tick.label.length == 0) continue;
			html.push('<div style="position:absolute;top:' + (this.plotOffset.top + this.tVert(tick.v) - this.labelMaxHeight/2) + 'px;left:0;width:' + this.labelMaxWidth + 'px;text-align:right" class="flotr-grid-label">' + tick.label + '</div>');
		}
		html.push('</div>');		
		this.el.insert(html.join(''));
	},
	/**
	 * Actually draws the graph.
	 * @param {Object} series - series to draw
	 */
	drawSeries: function(series){
		series = series || this.series;
		
		var drawn = false;
		for(var type in Flotr._registeredTypes){
			if(series[type] && series[type].show){
				this[Flotr._registeredTypes[type]](series);
				drawn = true;
			}
		}
		
		if(!drawn){
			this[Flotr._registeredTypes[this.options.defaultType]](series);
		}
	},
	
	plotLine: function(data, offset){
		var ctx = this.ctx,
			xa = this.xaxis,
			ya = this.yaxis;
			
		if(data.length < 2) return;

		var prevx = this.tHoz(data[0][0]),
			prevy = this.tVert(data[0][1]) + offset;

		ctx.beginPath();
		ctx.moveTo(prevx, prevy);
		for(var i = 0; i < data.length - 1; ++i){
			var x1 = data[i][0], y1 = data[i][1],
				x2 = data[i+1][0], y2 = data[i+1][1];

			/**
			 * Clip with ymin.
			 */
			if(y1 <= y2 && y1 < ya.min){
				/**
				 * Line segment is outside the drawing area.
				 */
				if(y2 < ya.min) continue;
				
				/**
				 * Compute new intersection point.
				 */
				x1 = (ya.min - y1) / (y2 - y1) * (x2 - x1) + x1;
				y1 = ya.min;
			}else if(y2 <= y1 && y2 < ya.min){
				if(y1 < ya.min) continue;
				x2 = (ya.min - y1) / (y2 - y1) * (x2 - x1) + x1;
				y2 = ya.min;
			}

			/**
			 * Clip with ymax.
			 */ 
			if(y1 >= y2 && y1 > ya.max) {
				if(y2 > ya.max) continue;
				x1 = (ya.max - y1) / (y2 - y1) * (x2 - x1) + x1;
				y1 = ya.max;
			}
			else if(y2 >= y1 && y2 > ya.max){
				if(y1 > ya.max) continue;
				x2 = (ya.max - y1) / (y2 - y1) * (x2 - x1) + x1;
				y2 = ya.max;
			}

			/**
			 * Clip with xmin.
			 */
			if(x1 <= x2 && x1 < xa.min){
				if(x2 < xa.min) continue;
				y1 = (xa.min - x1) / (x2 - x1) * (y2 - y1) + y1;
				x1 = xa.min;
			}else if(x2 <= x1 && x2 < xa.min){
				if(x1 < xa.min) continue;
				y2 = (xa.min - x1) / (x2 - x1) * (y2 - y1) + y1;
				x2 = xa.min;
			}

			/**
			 * Clip with xmax.
			 */
			if(x1 >= x2 && x1 > xa.max){
				if (x2 > xa.max) continue;
				y1 = (xa.max - x1) / (x2 - x1) * (y2 - y1) + y1;
				x1 = xa.max;
			}else if(x2 >= x1 && x2 > xa.max){
				if(x1 > xa.max) continue;
				y2 = (xa.max - x1) / (x2 - x1) * (y2 - y1) + y1;
				x2 = xa.max;
			}

			if(prevx != this.tHoz(x1) || prevy != this.tVert(y1) + offset)
				ctx.moveTo(this.tHoz(x1), this.tVert(y1) + offset);
			
			prevx = this.tHoz(x2);
			prevy = this.tVert(y2) + offset;
			ctx.lineTo(prevx, prevy);
		}
		ctx.stroke();
	},
	/**
	 * Function used to fill
	 * @param {Object} data
	 */
	plotLineArea: function(data){
		if(data.length < 2) return;

		var top, lastX = 0,
			ctx = this.ctx,
			xa = this.xaxis,
			ya = this.yaxis,
			bottom = Math.min(Math.max(0, ya.min), ya.max),
			first = true;
		
		ctx.beginPath();
		for(var i = 0; i < data.length - 1; ++i){
			
			var x1 = data[i][0], y1 = data[i][1],
				x2 = data[i+1][0], y2 = data[i+1][1];
			
			if(x1 <= x2 && x1 < xa.min){
				if(x2 < xa.min) continue;
				y1 = (xa.min - x1) / (x2 - x1) * (y2 - y1) + y1;
				x1 = xa.min;
			}else if(x2 <= x1 && x2 < xa.min){
				if(x1 < xa.min) continue;
				y2 = (xa.min - x1) / (x2 - x1) * (y2 - y1) + y1;
				x2 = xa.min;
			}
								
			if(x1 >= x2 && x1 > xa.max){
				if(x2 > xa.max) continue;
				y1 = (xa.max - x1) / (x2 - x1) * (y2 - y1) + y1;
				x1 = xa.max;
			}else if(x2 >= x1 && x2 > xa.max){
				if (x1 > xa.max) continue;
				y2 = (xa.max - x1) / (x2 - x1) * (y2 - y1) + y1;
				x2 = xa.max;
			}

			if(first){
				ctx.moveTo(this.tHoz(x1), this.tVert(bottom));
				first = false;
			}
			
			/**
			 * Now check the case where both is outside.
			 */
			if(y1 >= ya.max && y2 >= ya.max){
				ctx.lineTo(this.tHoz(x1), this.tVert(ya.max));
				ctx.lineTo(this.tHoz(x2), this.tVert(ya.max));
				continue;
			}else if(y1 <= ya.min && y2 <= ya.min){
				ctx.lineTo(this.tHoz(x1), this.tVert(ya.min));
				ctx.lineTo(this.tHoz(x2), this.tVert(ya.min));
				continue;
			}
			
			/**
			 * Else it's a bit more complicated, there might
			 * be two rectangles and two triangles we need to fill
			 * in; to find these keep track of the current x values.
			 */
			var x1old = x1, x2old = x2;
			
			/**
			 * And clip the y values, without shortcutting.
			 * Clip with ymin.
			 */
			if(y1 <= y2 && y1 < ya.min && y2 >= ya.min){
				x1 = (ya.min - y1) / (y2 - y1) * (x2 - x1) + x1;
				y1 = ya.min;
			}else if(y2 <= y1 && y2 < ya.min && y1 >= ya.min){
				x2 = (ya.min - y1) / (y2 - y1) * (x2 - x1) + x1;
				y2 = ya.min;
			}

			/**
			 * Clip with ymax.
			 */
			if(y1 >= y2 && y1 > ya.max && y2 <= ya.max){
				x1 = (ya.max - y1) / (y2 - y1) * (x2 - x1) + x1;
				y1 = ya.max;
			}else if(y2 >= y1 && y2 > ya.max && y1 <= ya.max){
				x2 = (ya.max - y1) / (y2 - y1) * (x2 - x1) + x1;
				y2 = ya.max;
			}

			/**
			 * If the x value was changed we got a rectangle to fill.
			 */
			if(x1 != x1old){
				top = (y1 <= ya.min) ? top = ya.min : ya.max;						
				ctx.lineTo(this.tHoz(x1old), this.tVert(top));
				ctx.lineTo(this.tHoz(x1), this.tVert(top));
			}
		   	
			/**
			 * Fill the triangles.
			 */
			ctx.lineTo(this.tHoz(x1), this.tVert(y1));
			ctx.lineTo(this.tHoz(x2), this.tVert(y2));

			/**
			 * Fill the other rectangle if it's there.
			 */
			if(x2 != x2old){
				top = (y2 <= ya.min) ? ya.min : ya.max;
				ctx.lineTo(this.tHoz(x2old), this.tVert(top));
				ctx.lineTo(this.tHoz(x2), this.tVert(top));
			}

			lastX = Math.max(x2, x2old);
		}
		
		ctx.lineTo(this.tHoz(lastX), this.tVert(bottom));
		ctx.closePath();
		ctx.fill();
	},
	/**
	 * Function: (private) drawSeriesLines
	 * 
	 * Function draws lines series in the canvas element.
	 * 
	 * Parameters:
	 * 		series - Series with options.lines.show = true.
	 * 
	 * Returns:
	 * 		void
	 */
	drawSeriesLines: function(series){
		series = series || this.series;
		var ctx = this.ctx;		
		ctx.save();
		ctx.translate(this.plotOffset.left, this.plotOffset.top);
		ctx.lineJoin = 'round';

		var lw = series.lines.lineWidth;
		var sw = series.shadowSize;
		/**
		 * @todo: consider another form of shadow when filling is turned on
		 */
		if(sw > 0){
			ctx.lineWidth = sw / 2;
			ctx.strokeStyle = "rgba(0,0,0,0.1)";
			this.plotLine(series.data, lw/2 + sw/2 + ctx.lineWidth/2);

			ctx.lineWidth = sw / 2;
			ctx.strokeStyle = "rgba(0,0,0,0.2)";
			this.plotLine(series.data, lw/2 + ctx.lineWidth/2);
		}

		ctx.lineWidth = lw;
		ctx.strokeStyle = series.color;
		if(series.lines.fill){
			ctx.fillStyle = series.lines.fillColor != null ? series.lines.fillColor : Flotr.parseColor(series.color).scale(null, null, null, series.lines.fillOpacity).toString();
			this.plotLineArea(series.data, 0);
		}

		this.plotLine(series.data, 0);
		ctx.restore();
	},
	/**
	 * Function: drawSeriesPoints
	 * 
	 * Function draws point series in the canvas element.
	 * 
	 * Parameters:
	 * 		series - Series with options.points.show = true.
	 * 
	 * Returns:
	 * 		void
	 */
	drawSeriesPoints: function(series) {
		var ctx = this.ctx,
			xaxis = this.xaxis,
			yaxis = this.yaxis,
			tHoz = this.tHoz.bind(this),
			tVert = this.tVert.bind(this);
			
		
		ctx.save();
		ctx.translate(this.plotOffset.left, this.plotOffset.top);

		var lw = series.lines.lineWidth;
		var sw = series.shadowSize;
		if(sw > 0){
			/**
			 * Draw fake shadow in two steps.
			 */
			ctx.lineWidth = sw / 2;
			ctx.strokeStyle = 'rgba(0,0,0,0.1)';
			this.plotPointShadows(series.data, sw/2 + ctx.lineWidth/2, series.points.radius);

			ctx.lineWidth = sw / 2;
			ctx.strokeStyle = 'rgba(0,0,0,0.2)';
			this.plotPointShadows(series.data, ctx.lineWidth/2, series.points.radius);
		}

		ctx.lineWidth = series.points.lineWidth;
		ctx.strokeStyle = series.color;
		ctx.fillStyle = series.points.fillColor != null ? series.points.fillColor : series.color;
		this.plotPoints(series.data, series.points.radius, series.points.fill);
		ctx.restore();
	},
	plotPoints: function (data, radius, fill) {
		var xaxis = this.xaxis,
			yaxis = this.yaxis,
			ctx = this.ctx;
			
		for(var i = data.length - 1; i > -1; --i){
			var x = data[i][0], y = data[i][1];
			if(x < xaxis.min || x > xaxis.max || y < yaxis.min || y > yaxis.max)
				continue;
			
			ctx.beginPath();
			ctx.arc(this.tHoz(x), this.tVert(y), radius, 0, 2 * Math.PI, true);
			if(fill) ctx.fill();
			ctx.stroke();
		}
	},
	plotPointShadows: function(data, offset, radius){
		var xaxis = this.xaxis,
			yaxis = this.yaxis,
			ctx = this.ctx, i;
			
		for(i = data.length - 1; i > -1; --i){
			var x = data[i][0], y = data[i][1];
			if (x < xaxis.min || x > xaxis.max || y < yaxis.min || y > yaxis.max)
				continue;
			ctx.beginPath();
			ctx.arc(this.tHoz(x), this.tVert(y) + offset, radius, 0, Math.PI, false);
			ctx.stroke();
		}
	},
	/**
	 * Function: drawSeriesBars
	 * 
	 * Function draws bar series in the canvas element.
	 * 
	 * Parameters:
	 * 		series - Series with options.bars.show = true.
	 * 
	 * Returns:
	 * 		void
	 */
	drawSeriesBars: function(series) {
		var ctx = this.ctx,
			bw = series.bars.barWidth,
			lw = Math.min(series.bars.lineWidth, bw);
		ctx.save();
		ctx.translate(this.plotOffset.left, this.plotOffset.top);
		ctx.lineJoin = 'round';

		/**
		 * @todo linewidth not interpreted the right way.
		 */
		/**
		 * @todo figure out a way to add shadows.
		 */
		/*
		var sw = series.shadowSize;
		if (sw > 0) {
			// draw shadow in two steps
			ctx.lineWidth = sw / 2;
			ctx.strokeStyle = "rgba(0,0,0,0.1)";
			plotBars(series.data, bw, lw/2 + sw/2 + ctx.lineWidth/2, false);

			ctx.lineWidth = sw / 2;
			ctx.strokeStyle = "rgba(0,0,0,0.2)";
			plotBars(series.data, bw, lw/2 + ctx.lineWidth/2, false);
		}*/

		ctx.lineWidth = lw;
		ctx.strokeStyle = series.color;
		if(series.bars.fill){
			ctx.fillStyle = series.bars.fillColor != null ? series.bars.fillColor : Flotr.parseColor(series.color).scale(null, null, null, series.bars.fillOpacity).toString();
		}

		this.plotBars(series.data, series, bw, 0, series.bars.fill);
		ctx.restore();
	},
	plotBars: function(data, series, barWidth, offset, fill){
		if(data.length < 1) return;
		
		var xaxis = this.xaxis,
			yaxis = this.yaxis,
			ctx = this.ctx,
			tHoz = this.tHoz.bind(this),
			tVert = this.tVert.bind(this);

		for(var i = 0; i < data.length; i++){
			var x = data[i][0], y = data[i][1];
			var drawLeft = true, drawTop = true, drawRight = true;
			if(series.bars.horizontal) var left = 0, right = x, bottom = y, top = y + barWidth;
			else var left = x, right = x + barWidth, bottom = 0, top = y;

			if(right < xaxis.min || left > xaxis.max || top < yaxis.min || bottom > yaxis.max)
				continue;

			if(left < xaxis.min){
				left = xaxis.min;
				drawLeft = false;
			}

			if(right > xaxis.max){
				right = xaxis.max;
				drawRight = false;
			}

			if(bottom < yaxis.min)
				bottom = yaxis.min;

			if(top > yaxis.max){
				top = yaxis.max;
				drawTop = false;
			}

			/**
			 * Fill the bar.
			 */
			if(fill){
				ctx.beginPath();
				ctx.moveTo(tHoz(left), tVert(bottom) + offset);
				ctx.lineTo(tHoz(left), tVert(top) + offset);
				ctx.lineTo(tHoz(right), tVert(top) + offset);
				ctx.lineTo(tHoz(right), tVert(bottom) + offset);
				ctx.fill();
			}

			/**
			 * Draw bar outline/border.
			 */
			if(series.bars.lineWidth != 0 && (drawLeft || drawRight || drawTop)){
				ctx.beginPath();
				ctx.moveTo(tHoz(left), tVert(bottom) + offset);
				if(drawLeft) ctx.lineTo(tHoz(left), tVert(top) + offset);
				else ctx.moveTo(tHoz(left), tVert(top) + offset);
				if(drawTop) ctx.lineTo(tHoz(right), tVert(top) + offset);
				else ctx.moveTo(tHoz(right), tVert(top) + offset);
				if(drawRight) ctx.lineTo(tHoz(right), tVert(bottom) + offset);
				else ctx.moveTo(tHoz(right), tVert(bottom) + offset);
				ctx.stroke();
			}
		}
	},
	/**
	 * Function: insertLegend
	 * 
	 * Function adds a legend div to the canvas container.
	 * 
	 * Parameters:
	 * 		none
	 * 
	 * Returns:
	 * 		void
	 */
	insertLegend: function(){
		if(!this.options.legend.show)
			return;
			
		var series =this.series,
			plotOffset = this.plotOffset,
			options = this.options,
			fragments = [],
			rowStarted = false, i;
			
		for(i = 0; i < series.length; ++i){
			if(!series[i].label) continue;
			
			if(i % options.legend.noColumns == 0){
				fragments.push((rowStarted) ? '</tr><tr>' : '<tr>');
				rowStarted = true;
			}

			var label = series[i].label;
			if(options.legend.labelFormatter != null)
				label = options.legend.labelFormatter(label);
			
			fragments.push('<td class="flotr-legend-color-box"><div style="border:1px solid ' + options.legend.labelBoxBorderColor + ';padding:1px"><div style="width:14px;height:10px;background-color:' + series[i].color + '"></div></div></td>' +
				'<td class="flotr-legend-label">' + label + '</td>');
		}
		if(rowStarted) fragments.push('</tr>');
		
		if(fragments.length > 0){
			var table = '<table style="font-size:smaller;color:' + options.grid.color + '">' + fragments.join("") + '</table>';
			if(options.legend.container != null){
				options.legend.container.append(table);
			}else{
				var pos = '';
				var p = options.legend.position, m = options.legend.margin;
				
				if(p.charAt(0) == 'n') pos += 'top:' + (m + plotOffset.top) + 'px;';
				else if(p.charAt(0) == 's') pos += 'bottom:' + (m + plotOffset.bottom) + 'px;';					
				if(p.charAt(1) == 'e') pos += 'right:' + (m + plotOffset.right) + 'px;';
				else if(p.charAt(1) == 'w') pos += 'left:' + (m + plotOffset.left) + 'px;';
				var div = this.el.insert('<div class="flotr-legend" style="position:absolute;z-index:2;' + pos +'">' + table + '</div>').getElementsBySelector('div.flotr-legend').first();
				
				if(options.legend.backgroundOpacity != 0.0){
					/**
					 * Put in the transparent background separately to avoid blended labels and
					 * label boxes.
					 */
					
					var c = options.legend.backgroundColor;
					if(c == null){
						var tmp = (options.grid.backgroundColor != null) ? options.grid.backgroundColor : Flotr.extractColor(div);
						c = Flotr.parseColor(tmp).adjust(null, null, null, 1).toString();
					}
					this.el.insert('<div class="flotr-legend-bg" style="position:absolute;width:' + div.getWidth() + 'px;height:' + div.getHeight() + 'px;' + pos +'background-color:' + c + ';"> </div>').select('div.flotr-legend-bg').first().setStyle({
						'opacity': options.legend.backgroundOpacity
					});						
				}
			}
		}
	},
	/**
	 * Function: getEventPosition
	 * 
	 * Calculates the coordinates from a mouse event object.
	 * 
	 * Parameters:
	 * 		event - Mouse Event object.
	 * 
	 * Returns:
	 * 		Object with x and y coordinates of the mouse.
	 */
	getEventPosition: function (event){
		var offset = this.overlay.cumulativeOffset(),
			rx = (event.pageX - offset.left - this.plotOffset.left),
			ry = (event.pageY - offset.top - this.plotOffset.top),
			ax = 0, ay = 0
			
		if(event.pageX == null && event.clientX != null){
			var de = document.documentElement, b = document.body;
			ax = event.clientX + (de && de.scrollLeft || b.scrollLeft || 0);
			ay = event.clientY + (de && de.scrollTop || b.scrollTop || 0);
		}else{
			ax = event.pageX;
			ay = event.pageY;
		}
		
		return {
			x: this.xaxis.min + rx / this.hozScale,
			y: this.yaxis.max - ry / this.vertScale,
			relX: rx,
			relY: ry,
			absX: ax,
			absY: ay
		};
	},
	/**
	 * Function: clickHandler
	 * 
	 * Handler observes the 'click' event and fires the 'flotr:click' event.
	 * 
	 * Parameters:
	 * 		event - 'click' Event object.
	 * 
	 * Returns:
	 * 		void
	 */
	clickHandler: function(event){
		if(this.ignoreClick){
			this.ignoreClick = false;
			return;
		}			
		this.el.fire('flotr:click', [this.getEventPosition(event), this]);
	},
	/**
	 * Function: mouseMoveHandler
	 * 
	 * Handler observes mouse movement over the graph area. Fires the 
	 * 'flotr:mousemove' event.
	 * 
	 * Parameters:
	 * 		event - 'mousemove' Event object.
	 * 
	 * Returns:
	 * 		void
	 */
	mouseMoveHandler: function(event){
 		var pos = this.getEventPosition(event);		
		this.lastMousePos.pageX = pos.absX;
		this.lastMousePos.pageY = pos.absY;	
		if((this.options.mouse.track || this.series.any(function(s){return s.mouse && s.mouse.track;})) && this.selectionInterval == null){	
			this.hit(pos);
		}			
		this.el.fire('flotr:mousemove', [event, pos, this]);
	},
	/**
	 * Function: mouseDownHandler
	 * 
	 * Handler observes the 'mousedown' event.
	 * 
	 * Parameters:
	 * 		event - 'mousedown' Event object.
	 * 
	 * Returns:
	 * 		void
	 */
	mouseDownHandler: function (event){
		if(!event.isLeftClick()) return;
		
		this.setSelectionPos(this.selection.first, event);				
		if(this.selectionInterval != null){
			clearInterval(this.selectionInterval);
		}
		this.lastMousePos.pageX = null;
		this.selectionInterval = setInterval(this.updateSelection.bind(this), 1000/this.options.selection.fps);
		
		$(document).observe('mouseup', this.mouseUpHandler.bind(this));
	},
	/**
	 * Function: (private) fireSelectEvent
	 * 
	 * Fires the 'flotr:select' event when the user made a selection.
	 * 
	 * Parameters:
	 * 		none
	 * 
	 * Returns:
	 * 		void
	 */
	fireSelectEvent: function(){
		var selection = this.selection,
			x1 = (selection.first.x <= selection.second.x) ? selection.first.x : selection.second.x,
			x2 = (selection.first.x <= selection.second.x) ? selection.second.x : selection.first.x,
			y1 = (selection.first.y >= selection.second.y) ? selection.first.y : selection.second.y,
			y2 = (selection.first.y >= selection.second.y) ? selection.second.y : selection.first.y;
		
		x1 = this.xaxis.min + x1 / this.hozScale;
		x2 = this.xaxis.min + x2 / this.hozScale;
		y1 = this.yaxis.max - y1 / this.vertScale;
		y2 = this.yaxis.max - y2 / this.vertScale;

		this.el.fire('flotr:select', [{x1:x1, y1:y1, x2:x2, y2:y2}, this]);
	},
	/**
	 * Function: (private) mouseUpHandler
	 * 
	 * Handler observes the mouseup event for the document. 
	 * 
	 * Parameters:
	 * 		event - 'mouseup' Event object.
	 * 
	 * Returns:
	 * 		void
	 */
	mouseUpHandler: function(event){
		$(document).stopObserving('mouseup', this.mouseUpHandler);
		Event.stop(event);
		
		if(this.selectionInterval != null){
			clearInterval(this.selectionInterval);
			this.selectionInterval = null;
		}

		this.setSelectionPos(this.selection.second, event);
		this.clearSelection();
		
		if(this.selectionIsSane() || event.isLeftClick()){
			this.drawSelection();
			this.fireSelectEvent();
			this.ignoreClick = true;
		}
	},
	/**
	 * Function: setSelectionPos
	 * 
	 * Calculates the position of the selection.
	 * 
	 * Parameters:
	 * 		pos - Position object.
	 * 		event - Event object.
	 * 
	 * Returns:
	 * 		void
	 */
	setSelectionPos: function(pos, event) {
		var options = this.options,
			offset = $(this.overlay).cumulativeOffset();
		if(options.selection.mode == 'y'){
			pos.x = (pos == selection.first) ? 0 : this.plotWidth;			   
		}else{
			pos.x = event.pageX - offset.left - this.plotOffset.left;
			pos.x = Math.min(Math.max(0, pos.x), this.plotWidth);
		}

		if (options.selection.mode == 'x'){
			pos.y = (pos == selection.first) ? 0: this.plotHeight;
		}else{
			pos.y = event.pageY - offset.top - this.plotOffset.top;
			pos.y = Math.min(Math.max(0, pos.y), this.plotHeight);
		}
	},
	/**
	 * Function: updateSelection
	 * 
	 * Updates (draws) the selection box.
	 * 
	 * Parameters:
	 * 		none
	 * 
	 * Returns:
	 * 		void
	 */
	updateSelection: function(){
		if(this.lastMousePos.pageX == null) return;
		
		this.setSelectionPos(this.selection.second, this.lastMousePos);
		this.clearSelection();
		
		if(this.selectionIsSane()) this.drawSelection();
	},
	/**
	 * Function: clearSelection
	 * 
	 * Removes the selection box from the overlay canvas.
	 * 
	 * Parameters:
	 * 		none
	 * 
	 * Returns:
	 * 		void
	 */
	clearSelection: function() {
		if(this.prevSelection == null) return;
			
		var prevSelection = this.prevSelection,
			octx = this.octx,
			plotOffset = this.plotOffset,
			x = Math.min(prevSelection.first.x, prevSelection.second.x),
			y = Math.min(prevSelection.first.y, prevSelection.second.y),
			w = Math.abs(prevSelection.second.x - prevSelection.first.x),
			h = Math.abs(prevSelection.second.y - prevSelection.first.y);
		
		octx.clearRect(x + plotOffset.left - octx.lineWidth,
					   y + plotOffset.top - octx.lineWidth,
					   w + octx.lineWidth*2,
					   h + octx.lineWidth*2);
		
		this.prevSelection = null;
	},
	/**
	 * Function: setSelection
	 * 
	 * Allows the user the manually select an area.
	 * 
	 * Parameters:
	 * 		area - Object with coordinates to select.
	 * 
	 * Returns:
	 * 		void
	 */
	setSelection: function(area){
		var options = this.options,
			xaxis = this.xaxis,
			yaxis = this.yaxis,
			vertScale = this.vertScale,
			hozScale = this.hozScale;
		this.clearSelection();
					
		this.selection.first.y = (options.selection.mode == 'x') ? 0 : (yaxis.max - area.y1) * vertScale;
		this.selection.second.y = (options.selection.mode == 'x') ? this.plotHeight : (yaxis.max - area.y2) * vertScale;			
		this.selection.first.x = (options.selection.mode == 'y') ? 0 : (area.x1 - xaxis.min) * hozScale;
		this.selection.second.x = (options.selection.mode == 'y') ? this.plotWidth : (area.x2 - xaxis.min) * hozScale;
		
		this.drawSelection();
		this.fireSelectEvent();
	},
	/**
	 * Function: (private) drawSelection
	 * 
	 * Draws the selection box.
	 * 
	 * Parameters:
	 * 		none
	 * 
	 * Returns:
	 * 		void
	 */
	drawSelection: function() {
		var prevSelection = this.prevSelection,
			selection = this.selection,
			octx = this.octx,
			options = this.options,
			plotOffset = this.plotOffset;
		if(prevSelection != null &&
			selection.first.x == prevSelection.first.x &&
			selection.first.y == prevSelection.first.y && 
			selection.second.x == prevSelection.second.x &&
			selection.second.y == prevSelection.second.y)
			return;
		
		octx.strokeStyle = Flotr.parseColor(options.selection.color).scale(null, null, null, 0.8).toString();
		octx.lineWidth = 1;
		octx.lineJoin = 'round';
		octx.fillStyle = Flotr.parseColor(options.selection.color).scale(null, null, null, 0.4).toString();

		this.prevSelection = { first:  { x: selection.first.x,
									y: selection.first.y },
						  second: { x: selection.second.x,
									y: selection.second.y } };

		var x = Math.min(selection.first.x, selection.second.x),
			y = Math.min(selection.first.y, selection.second.y),
			w = Math.abs(selection.second.x - selection.first.x),
			h = Math.abs(selection.second.y - selection.first.y);
		
		octx.fillRect(x + plotOffset.left, y + plotOffset.top, w, h);
		octx.strokeRect(x + plotOffset.left, y + plotOffset.top, w, h);
	},
	/**
	 * Function: (private) selectionIsSane
	 * 
	 * Determines whether or not the selection is sane and should be drawn.
	 * 
	 * Parameters:
	 * 		none
	 * 
	 * Returns:
	 * 		boolean - True when sane, false otherwise.
	 */
	selectionIsSane: function(){
		var selection = this.selection;
		return Math.abs(selection.second.x - selection.first.x) >= 5 &&
			Math.abs(selection.second.y - selection.first.y) >= 5;
	},
	/**
	 * Function: clearHit
	 * 
	 * Removes the mouse tracking point from the overlay.
	 * 
	 * Parameters:
	 * 		none
	 * 
	 * Returns:
	 * 		void
	 */
	clearHit: function(){
		if(this.prevHit){
			var options = this.options,
				plotOffset = this.plotOffset,
				prevHit = this.prevHit;		
					
			this.octx.clearRect(
				this.tHoz(prevHit.x) + plotOffset.left - options.points.radius*2,
				this.tVert(prevHit.y) + plotOffset.top - options.points.radius*2,
				options.points.radius*3 + options.points.lineWidth*3, 
				options.points.radius*3 + options.points.lineWidth*3
			);
			this.prevHit = null;
		}		
	},
	/**
	 * Function: hit
	 * 
	 * Retrieves the nearest data point from the mouse cursor. If it's within
	 * a certain range, draw a point on the overlay canvas and display the x and y
	 * value of the data.
	 * 
	 * Parameters:
	 * 		mouse - Object that holds the relative x and y coordinates of the cursor.
	 * 
	 * Returns:
	 * 		void
	 */
	hit: function(mouse){			
		
		var series = this.series,
			options = this.options,
			prevHit = this.prevHit,
			plotOffset = this.plotOffset,
			octx = this.octx, 
			data, xsens, ysens,
			/**
			 * Nearest data element.
			 */
			i, n = {
				dist:Number.MAX_VALUE,
				x:null,
				y:null,
				relX:mouse.relX,
				relY:mouse.relY,
				absX:mouse.absX,
				absY:mouse.absY,
				mouse:null
			};
		
		for(i = 0; i < series.length; i++){
			if(!series[i].mouse.track) continue;
			data = series[i].data;		
			xsens = (this.hozScale*series[i].mouse.sensibility);
			ysens = (this.vertScale*series[i].mouse.sensibility);
			for(var j = 0, xpow, ypow; j < data.length; j++){
				xpow = Math.pow(this.hozScale*(data[j][0] - mouse.x), 2);
				ypow = Math.pow(this.vertScale*(data[j][1] - mouse.y), 2);
				if(xpow < xsens && ypow < ysens && Math.sqrt(xpow+ypow) < n.dist){
					n.dist = Math.sqrt(xpow+ypow);
					n.x = data[j][0];
					n.y = data[j][1];
					n.mouse = series[i].mouse;
				}
			}
		}
		
		if(n.mouse && n.mouse.track && !prevHit || (prevHit && n.x != prevHit.x && n.y != prevHit.y)){
			var el = this.el.select('.flotr-mouse-value').first();
			if(!el){
				var pos = '', p = options.mouse.position, m = options.mouse.margin;					
				if(p.charAt(0) == 'n') pos += 'top:' + (m + plotOffset.top) + 'px;';
				else if(p.charAt(0) == 's') pos += 'bottom:' + (m + plotOffset.bottom) + 'px;';					
				if(p.charAt(1) == 'e') pos += 'right:' + (m + plotOffset.right) + 'px;';
				else if(p.charAt(1) == 'w') pos += 'left:' + (m + plotOffset.left) + 'px;';
				
				this.el.insert('<div class="flotr-mouse-value" style="opacity:0.7;background-color:#000;color:#fff;display:none;position:absolute;'+pos+'"></div>');
				return;
			}
			if(n.x !== null && n.y !== null){
				el.setStyle({display:'block'});					
				
				this.clearHit();
				if(n.mouse.lineColor != null){
					octx.save();
					octx.translate(plotOffset.left, plotOffset.top);
					octx.lineWidth = options.points.lineWidth;
					octx.strokeStyle = n.mouse.lineColor;
					octx.fillStyle = '#ffffff';
					octx.beginPath();
					octx.arc(this.tHoz(n.x), this.tVert(n.y), options.mouse.radius, 0, 2 * Math.PI, true);
					octx.fill();
					octx.stroke();
					octx.restore();
				} 
				this.prevHit = n;
								
				var decimals = n.mouse.trackDecimals;
				if(decimals == null || decimals < 0) decimals = 0;
				
				el.innerHTML = n.mouse.trackFormatter({x: n.x.toFixed(decimals), y: n.y.toFixed(decimals)});
				this.el.fire( 'flotr:hit', [n, this] )					
			}else if(prevHit){
				el.setStyle({display:'none'});
				this.clearHit();
			}
		}
	}
});

Flotr.Color = Class.create({
	initialize: function(r, g, b, a){
		this.rgba = ['r','g','b','a'];
		var x = 4;
		while(-1<--x){
			this[this.rgba[x]] = arguments[x] || ((x==3) ? 1.0 : 0);
		}
		this.normalize();
	},
	
	adjust: function(rd, gd, bd, ad) {
		var x = 4;
		while(-1<--x){
			if(arguments[x] != null)
				this[this.rgba[x]] += arguments[x];
		}
		return this.normalize();
	},
	
	clone: function(){
		return new Flotr.Color(this.r, this.b, this.g, this.a);
	},
	
	limit: function(val,minVal,maxVal){
		return Math.max(Math.min(val, maxVal), minVal);
	},
	
	normalize: function(){
		var limit = this.limit;
		this.r = limit(parseInt(this.r), 0, 255);
		this.g = limit(parseInt(this.g), 0, 255);
		this.b = limit(parseInt(this.b), 0, 255);
		this.a = limit(this.a, 0, 1);
		return this;
	},
	
	scale: function(rf, gf, bf, af) {
		var x = 4;
		while(-1<--x){
			if(arguments[x] != null)
				this[this.rgba[x]] *= arguments[x];
		}
		return this.normalize();
	},
	
	toString: function(){
		return (this.a >= 1.0) ? 'rgb('+[this.r,this.g,this.b].join(',')+')' : 'rgba('+[this.r,this.g,this.b,this.a].join(',')+')';
	}
});

Flotr.Color.lookupColors = {
	aqua:[0,255,255],
	azure:[240,255,255],
	beige:[245,245,220],
	black:[0,0,0],
	blue:[0,0,255],
	brown:[165,42,42],
	cyan:[0,255,255],
	darkblue:[0,0,139],
	darkcyan:[0,139,139],
	darkgrey:[169,169,169],
	darkgreen:[0,100,0],
	darkkhaki:[189,183,107],
	darkmagenta:[139,0,139],
	darkolivegreen:[85,107,47],
	darkorange:[255,140,0],
	darkorchid:[153,50,204],
	darkred:[139,0,0],
	darksalmon:[233,150,122],
	darkviolet:[148,0,211],
	fuchsia:[255,0,255],
	gold:[255,215,0],
	green:[0,128,0],
	indigo:[75,0,130],
	khaki:[240,230,140],
	lightblue:[173,216,230],
	lightcyan:[224,255,255],
	lightgreen:[144,238,144],
	lightgrey:[211,211,211],
	lightpink:[255,182,193],
	lightyellow:[255,255,224],
	lime:[0,255,0],
	magenta:[255,0,255],
	maroon:[128,0,0],
	navy:[0,0,128],
	olive:[128,128,0],
	orange:[255,165,0],
	pink:[255,192,203],
	purple:[128,0,128],
	violet:[128,0,128],
	red:[255,0,0],
	silver:[192,192,192],
	white:[255,255,255],
	yellow:[255,255,0]
};
