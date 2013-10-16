'use strict';
################################################
# appier.edash
###############################################
edash=angular.module('appier.edash',['ngResource'])

edash.factory 'statistics',['$resource',($resource)->
	console.log 'edash>statistics init'
	return $resource '/api/statistics/:io_id/:campaign_id?unit=:unit&start=:start&stop=:stop',{
			io_id:"@io_id"
			campaign_id:"@campaign_id"
			unit:"@"
			start:"@start"
			stop:"@stop"
		},{
			getList:{
				method:'GET'
				params:{
					campaign_id:0
				}
			},
			###	
			total:{method:"GET",params:{op:'total'},responseType:"text"}
			addTotal:{method:"PUT",params:{op:'total'}}
			all:{method:"GET",params:{op:'phone'},isArray:true}
			#,headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'}
			add:{method:"POST",params:{op:'phone'}}
			del:{method:"DELETE",params:{op:'phone'}}
			###
		}
]


#########################################
# directive: Appier Statistics Chart
# attr:
# 	io_id
# 	campaign_id
# 	set_id
#		start
#		stop
##########################################
edash.directive 'edashStatisticsChart',['statistics',(statistics)->
	return {
		restrict:'EA'
		template:"""
			<div class="edash-statistics-chart">
				<h5>edash statistics chart</h5>
				<div class="top-chart" style="width:{{width}}px;height:{{height}}px"></div>
				<div>
					time:{{currentData.rows[currentRowIndex].time*1000|date:'yyyy/MM/dd HH:mm:ss'}}<br/>
					budget:{{currentData.rows[currentRowIndex].cost|number}}<br/>
					impressions:{{currentData.rows[currentRowIndex].impressions}}</br>
					click:{{currentData.rows[currentRowIndex].clicks}}<br/>
					action:{{currentData.rows[currentRowIndex].actions}}<br/>
					cpc:{{0.0000001*currentData.rows[currentRowIndex].cost/currentData.rows[currentRowIndex].clicks}}<br/>
					cpa:{{0.0000001*currentData.rows[currentRowIndex].cost/currentData.rows[currentRowIndex].actions}}<br/>
				</div>
			</div>
		"""
		scope:
			'chartSource':'=',
			'onRenderStart':'&'
			'onRenderComplete':'&'
		link:(scope,element,attr)->
			console.log '[edash]edash-statistics-chart'
			console.dir statistics
			console.dir scope

			#chart setting
			scope.width=800
			scope.height=300
			scope.chart=null
			scope.plotDataSet=null
			scope.currentData=null
			scope.currentRowIndex=0
	
			#default plot optons
			scope.plotOptions=
				xaxis:
					tickLength:0
					ticks:5
					axisLabel:'date'
					tickFormatter:(val,obj)->
						moment.unix(val).format('YYYY/MM/DD')
				yaxes:[
						position:'left'
						axisLabel:'budget($)'
						axisLabelUseCanvas: true
						tickDecimals:2
						tickFormatter:(val,obj)->
							#us dolor
							return Math.floor(val*0.0000001)
						axisLabelFontSizePixels: 12,
						axisLabelFontFamily: 'Verdana, Arial',
						axisLabelPadding: 3
					,
						position:'left'
						axisLabel:'impressions'
						axisLabelUseCanvas: true
					,
						position:'left'
						axisLabel:'click,action'
						axisLabelUseCanvas: true
					,
						position:'right'
						axisLabel:'cpc'
						axisLabelUseCanvas: true
						tickFormatter:(val,obj)->
							return (val*0.0000001).toFixed(2)
					,
            position:'right'
            axisLabel:'cpa'
            axisLabelUseCanvas: true
            tickFormatter:(val,obj)->
              return (val*0.0000001).toFixed(2)
				]
				legend:
					noColumns:true
				grid:
					hoverable:true
					borderWidth: 3
					backgroundColor:
						colors: ["#ffffff", "#EDF5FF"]
					#labelMargin: 10,
					#backgroundColor: '#e2e6e9',
					#color: '#ffffff',
					#borderColor: null
				crosshair:
					mode:'xy'
					color:'#ccccff'

			scope.onChartSourceChange=(newVal,oldVal)->
				console.log "onChartDataChange"
				if newVal
					statistics.getList {
						io_id:newVal.io_id
						campaign_id:newVal.campaign_id
						set_id:newVal.set_id
						start:newVal.start
						stop:newVal.stop
						unit:newVal.unit
					},(response)->
						console.log '[edash]statistics.getList'
						scope.currentData=response
						scope.parseData(response)
				


			#parse ngModel
			scope.parseData=(data)->
				console.log '[edash]parseData'
				#console.dir data
				tmpData=
					cost:[]
					impressions:[]
					clicks:[]
					actions:[]
					views:[]
					ctr:[]
					cpc:[]
					cvr:[]
					cpa:[]
				
				_.each data.rows,(row, key, list)->
					key=parseInt key
					if !_.isNumber(key)
						return
					if !row.cost
						return

					row.time=key
					tmpData.cost.push [row.time,row.cost] # moneny
					tmpData.impressions.push [row.time,row.impressions] # num
					tmpData.clicks.push [row.time,row.clicks] #num
					tmpData.views.push [row.time,row.views] #num
					tmpData.actions.push [row.time,row.actions] #num
					tmpData.cpc.push [row.time,if row.clicks>0 then row.cost/row.clicks else 0] #num
					tmpData.cpa.push [row.time,if row.actions>0 then row.cost/row.actions else 0] #num
					tmpData.ctr.push [row.time,row.clicks/row.impressions] #% click
					tmpData.cvr.push [row.time,row.actions/row.clicks] #% actions:click
				
				scope.plotDataSet=[
						label:'cost'
						data:tmpData.cost
						yaxis:1
						lines:
							show:true
							fill:true
					,
						label:'impression'
						data:tmpData.impressions
						yaxis:2
						lines:
							show:true
					,
						label:'click'
						data:tmpData.clicks
						yaxis:3
						lines:
							show:true
					#,
					#	label:'view'
					#	data:tmpData.views
					#	yaxis:2
					#	lines:
					#		show:true
					,
						label:'action'
						data:tmpData.actions
						yaxis:3
						lines:
							show:true
					,
						label:'cpc'
						data:tmpData.cpc
						yaxis:4
						bars:
							show: true
							align: "center"
							barWidth:scope.currentData.unit*0.5
							lineWidth:1
					,
						label:'cpa'
						data:tmpData.cpa
						yaxis:5
						bars:
							show:true
							align: "center"
							barWidth:scope.currentData.unit*0.5
							lineWidth:1
				]
				#cpc max
				tmpMax=_.max tmpData.cpc,(row)->
          row[1]
				scope.plotOptions.yaxes[3].max=tmpMax[1]*2
				#cpa max
				tmpMax=_.max tmpData.cpa,(row)->
          row[1]
				scope.plotOptions.yaxes[4].max=tmpMax[1]*2

				console.log "options"
				console.dir scope.plotOptions
				scope.render scope.plotDataSet

			scope.render=(dataSet)->
				console.log 'render'
				console.dir dataSet
				if !scope.chart
					scope.chart=$.plot $('.top-chart',element),dataSet,scope.plotOptions
					$('.top-chart',element).bind "plothover",scope.onPoltHover
				else
					scope.chart.setData dataSet
					scope.chart.setupGrid()
					scope.chart.draw()
	
			scope.onPoltHover=(event, pos, item)->
				#console.log 'onPoltHover'
				tmpTime=pos.x
				#console.log moment.unix(tmpTime).format("YYYY/MM/DD")
				for i,row of scope.currentData.rows
					if row.time >= tmpTime
						console.log i,moment.unix(tmpTime).format("YYYY/MM/DD")
						scope.currentRowIndex=i
						scope.$digest()
						break

			scope.$watch 'chartSource',scope.onChartSourceChange,true
			scope.$watch 'currentRowIndex',()->
				console.log "CHANGE:"+scope.currentRowIndex
				if scope.currentData && scope.currentRowIndex
					console.dir scope.currentData.rows[scope.currentRowIndex]
			
	}]


@app.controller 'MainCtrl',['$scope','statistics',($scope,statistics)->
	console.log 'run do MainCtrl'
	
	$scope.title="Hello World"
	$scope.message="ummm......"

	$scope.chartData=
		io_id:1
		campaign_id:1
		set_id:1
		unit:'day'
		start:Math.floor((new Date()).getTime()*0.001)
		stop:Math.floor((new Date()).getTime()*0.001)
	console.dir $scope.chartData
]
