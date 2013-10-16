/**
 * Module dependencies.
 */

var express = require('express')
		, fs = require('fs')
    , http = require('http')
    , path = require('path')
		, moment = require('moment')
		, csv = require('csv')
		, stringify = require('stringify')
		, clc = require('cli-color')
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

app.get(/^\/api\/statistics/,function(req,res){
	readCSV(req,res);
});

http.createServer(app).listen(app.get('port'), function () {
    console.log("Express server listening on port %d in %s mode", app.get('port'), app.get('env'));
});

function readCSV(req,res){
	file="data/cmp_2.csv";
	fs.readFile(file, 'utf8', function (err, data) {
    if (err) {
      console.log(clc.red('Error: ' + err));
      return;
    }
		
    //data = JSON.parse(data);
   	//res.send(data);
		csv().from
			.string(data,{comment: '#'} )
			.to.array( function(data){
				console.log(data)
				var rows={}
				for(var i=0;i<data.length;i++){
					row={}
					//09-20 02:00(TW)
					var timeStr=data[i][0];
					key='2013-'+timeStr.slice(0,5)
					key+=' '+timeStr.slice(6,11)+':00';
					key=moment(key).format('X')
					
					row.impressions=data[i][1];	
					row.clicks=parseInt(data[i][2]);
					row.actions=parseInt(data[i][3]);
					row.cost=data[i][4]*10000000;
					rows[key]=row
				}
				var response={
					rows:rows,
					unit:3600
				}
				res.send(JSON.stringify(response))
			});
			//res.send("Hello");
  });


}
function readJSON(){
  file='data/cmp_1.json';
  fs.readFile(file, 'utf8', function (err, data) {
    if (err) {
      console.log(clc.red('Error: ' + err));
      return;
    }
    //data = JSON.parse(data);
    res.send(data);
  });
}
function randomData(){
  var today=(new Date()).getTime()*0.001;
  today=today-today%86400
  var rows=[]
  for(var i=0;i<31;i++){
    var time=today+i*86400;
    var row={}
    //row.time=moment.unix(today+i*86400).format('YYYY/MM/DD')
    row.time=time;

    row.cost=Math.floor(Math.random()*10000);

    row.impressions=Math.floor(Math.random()*100000);
    row.clicks=Math.floor(Math.random()*100);
    row.actions=Math.floor(Math.random()*100);
    row.views=Math.floor(Math.random()*100);

    row.wins=Math.floor(Math.random()*100);
    row.bids=Math.floor(Math.random()*100);
    rows.push(row)
  }
  var response={rows:rows}
	return response;
}
