/**
 * Module dependencies.
 */

var express = require('express')
    , http = require('http')
    , path = require('path')
		, moment=require('moment')
		, stringify = require('stringify')

var app = express();

// all environments
app.set('port', process.env.PORT || 3000);

app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(app.router);

// development only
if ('production' == app.get('env')) {
    app.use(express.static(path.join(__dirname, 'dist')));
} else {
    app.use(express.static(path.join(__dirname, 'app')));
		app.use(express.static(path.join(__dirname, '.tmp')));
    app.use(express.errorHandler());
}

app.get('/login',function(req,res){
	//res.send("login");
	res.send(moment().format());
});


app.get('/statistics',function(req,res){
	var today=(new Date()).getTime()*0.001;
	today=today-today%86400
	var response=[]
	for(var i=0;i<31;i++){
		var time=today+i*86400;
		var row={}
		row.time=moment.unix(today+i*86400).format('YYYY/MM/DD')

		row.cost=Math.floor(Math.random()*10000)
		row.impressions=Math.floor(Math.random()*10000)
		row.clicks=Math.floor(Math.random()*10000)
		row.actions=Math.floor(Math.random()*10000)
		row.view=Math.floor(Math.random()*10000)

		response.push(row)
	}
	res.send(JSON.stringify(response))
});

http.createServer(app).listen(app.get('port'), function () {
    console.log("Express server listening on port %d in %s mode", app.get('port'), app.get('env'));
});

